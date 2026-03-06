import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/transaction_status.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TransactionRepositoryImpl(
    this._firestore,
    this._auth,
  );

  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      _firestore.collection('transactions');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _experiencesCollection =>
      _firestore.collection('experiences');

  @override
  Future<Either<AppException, List<Transaction>>> getTransactionHistory({
    required String userId,
    int limit = 20,
    String? lastTransactionId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _transactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastTransactionId != null) {
        final lastDoc =
            await _transactionsCollection.doc(lastTransactionId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();

      final transactions = snapshot.docs
          .map((doc) => Transaction.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      return Right(transactions);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to load transaction history: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        DatabaseException(
          message: 'Unexpected error loading transactions: $e',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Transaction>> createPurchase({
    required String experienceId,
    required String sellerId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? referralCode,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(
          AuthException(message: 'User not authenticated'),
        );
      }

      // Check if user already purchased this experience
      final existingPurchase = await _transactionsCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('experienceId', isEqualTo: experienceId)
          .where('type', isEqualTo: TransactionType.purchase.name)
          .where('status', whereIn: [
            TransactionStatus.completed.name,
            TransactionStatus.pending.name,
          ])
          .limit(1)
          .get();

      if (existingPurchase.docs.isNotEmpty) {
        return Left(
          ValidationException(
            message: 'You have already purchased this experience',
          ),
        );
      }

      // Get experience details
      final experienceDoc = await _experiencesCollection.doc(experienceId).get();
      if (!experienceDoc.exists) {
        return Left(
          NotFoundException(message: 'Experience not found'),
        );
      }

      final experienceData = experienceDoc.data()!;
      final price = (experienceData['price'] as num).toDouble();

      // Validate amount matches price
      if (amount != price) {
        return Left(
          ValidationException(
            message: 'Payment amount does not match experience price',
          ),
        );
      }

      // Calculate revenue split
      final revenueSplit = _calculateRevenueSplit(
        amount: amount,
        referralCode: referralCode,
      );

      // Create transaction document
      final transactionRef = _transactionsCollection.doc();
      final transaction = Transaction(
        id: transactionRef.id,
        userId: currentUser.uid,
        experienceId: experienceId,
        sellerId: sellerId,
        amount: amount,
        type: TransactionType.purchase,
        status: TransactionStatus.pending,
        paymentMethod: paymentMethod,
        metadata: {
          'revenueSplit': revenueSplit,
          'referralCode': referralCode,
          'experienceTitle': experienceData['title'],
          'experienceType': experienceData['type'],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use transaction to ensure atomic updates
      await _firestore.runTransaction((firestoreTransaction) async {
        // Create transaction record
        firestoreTransaction.set(transactionRef, transaction.toJson());

        // Update user's purchases list
        final userRef = _usersCollection.doc(currentUser.uid);
        firestoreTransaction.update(userRef, {
          'purchases': FieldValue.arrayUnion([experienceId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Increment experience sales count
        final expRef = _experiencesCollection.doc(experienceId);
        firestoreTransaction.update(expRef, {
          'salesCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Process payment based on method
      final paymentResult = await _processPayment(
        transaction: transaction,
        paymentMethod: paymentMethod,
      );

      return paymentResult.fold(
        (failure) async {
          // Update transaction status to failed
          await transactionRef.update({
            'status': TransactionStatus.failed.name,
            'errorMessage': failure.message,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return Left(failure);
        },
        (success) async {
          // Update transaction status to completed
          await transactionRef.update({
            'status': TransactionStatus.completed.name,
            'completedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Update seller's earnings
          await _updateSellerEarnings(
            sellerId: sellerId,
            amount: revenueSplit['creator'] ?? 0,
          );

          // Process referral bonus if applicable
          if (referralCode != null && revenueSplit['referral'] != null) {
            await _processReferralBonus(
              referralCode: referralCode,
              amount: revenueSplit['referral']!,
              transactionId: transactionRef.id,
            );
          }

          return Right(transaction.copyWith(
            status: TransactionStatus.completed,
          ));
        },
      );
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to create purchase: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(
          message: 'Unexpected error during purchase: $e',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Transaction>> processWithdrawal({
    required double amount,
    required PaymentMethod paymentMethod,
    required Map<String, dynamic> withdrawalDetails,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      // Validate minimum withdrawal amount
      if (amount < 10.0) {
        return Left(
          ValidationException(
            message: 'Minimum withdrawal amount is \$10.00',
          ),
        );
      }

      // Check user's available balance
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      if (!userDoc.exists) {
        return Left(NotFoundException(message: 'User not found'));
      }

      final userData = userDoc.data()!;
      final earnings = (userData['earnings'] as num?)?.toDouble() ?? 0.0;
      final withdrawn = (userData['withdrawn'] as num?)?.toDouble() ?? 0.0;
      final availableBalance = earnings - withdrawn;

      if (availableBalance < amount) {
        return Left(
          ValidationException(
            message:
                'Insufficient balance. Available: \$${availableBalance.toStringAsFixed(2)}',
          ),
        );
      }

      // Create withdrawal transaction
      final transactionRef = _transactionsCollection.doc();
      final transaction = Transaction(
        id: transactionRef.id,
        userId: currentUser.uid,
        amount: amount,
        type: TransactionType.withdrawal,
        status: TransactionStatus.pending,
        paymentMethod: paymentMethod,
        metadata: {
          'withdrawalDetails': withdrawalDetails,
          'availableBalanceBefore': availableBalance,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionRef.set(transaction.toJson());

      // Update user's withdrawn amount
      await _usersCollection.doc(currentUser.uid).update({
        'withdrawn': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Process withdrawal based on payment method
      final withdrawalResult = await _processWithdrawalPayment(
        transaction: transaction,
        paymentMethod: paymentMethod,
        withdrawalDetails: withdrawalDetails,
      );

      return withdrawalResult.fold(
        (failure) async {
          await transactionRef.update({
            'status': TransactionStatus.failed.name,
            'errorMessage': failure.message,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Rollback withdrawn amount
          await _usersCollection.doc(currentUser.uid).update({
            'withdrawn': FieldValue.increment(-amount),
          });

          return Left(failure);
        },
        (success) async {
          await transactionRef.update({
            'status': TransactionStatus.completed.name,
            'completedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return Right(transaction.copyWith(
            status: TransactionStatus.completed,
          ));
        },
      );
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to process withdrawal: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error during withdrawal: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, double>> getBalance(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return Left(NotFoundException(message: 'User not found'));
      }

      final userData = userDoc.data()!;
      final earnings = (userData['earnings'] as num?)?.toDouble() ?? 0.0;
      final withdrawn = (userData['withdrawn'] as num?)?.toDouble() ?? 0.0;

      return Right(earnings - withdrawn);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get balance: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error getting balance: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, double>> getTotalEarnings(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return Left(NotFoundException(message: 'User not found'));
      }

      final userData = userDoc.data()!;
      final earnings = (userData['earnings'] as num?)?.toDouble() ?? 0.0;

      return Right(earnings);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get earnings: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error getting earnings: $e'),
      );
    }
  }

  @override
  Stream<Either<AppException, List<Transaction>>> transactionStream({
    required String userId,
    int limit = 50,
  }) async* {
    try {
      final stream = _transactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();

      await for (final snapshot in stream) {
        final transactions = snapshot.docs
            .map((doc) => Transaction.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();

        yield Right(transactions);
      }
    } on FirebaseException catch (e) {
      yield Left(
        DatabaseException(
          message: 'Failed to stream transactions: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      yield Left(
        UnknownException(message: 'Unexpected error in transaction stream: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, Transaction?>> getPendingTransaction(
    String experienceId,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('experienceId', isEqualTo: experienceId)
          .where('status', isEqualTo: TransactionStatus.pending.name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      final doc = snapshot.docs.first;
      final transaction = Transaction.fromJson({
        'id': doc.id,
        ...doc.data(),
      });

      return Right(transaction);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get pending transaction: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, Transaction>> refundTransaction(
    String transactionId,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      final transactionDoc = await _transactionsCollection.doc(transactionId).get();
      if (!transactionDoc.exists) {
        return Left(NotFoundException(message: 'Transaction not found'));
      }

      final transaction = Transaction.fromJson({
        'id': transactionDoc.id,
        ...transactionDoc.data()!,
      });

      // Only allow refund for completed purchases within 24 hours
      if (transaction.type != TransactionType.purchase ||
          transaction.status != TransactionStatus.completed) {
        return Left(
          ValidationException(message: 'Transaction cannot be refunded'),
        );
      }

      final timeSincePurchase = DateTime.now().difference(transaction.createdAt);
      if (timeSincePurchase.inHours > 24) {
        return Left(
          ValidationException(
            message: 'Refund period has expired (24 hours)',
          ),
        );
      }

      // Create refund transaction
      final refundRef = _transactionsCollection.doc();
      final refund = Transaction(
        id: refundRef.id,
        userId: currentUser.uid,
        experienceId: transaction.experienceId,
        sellerId: transaction.sellerId,
        amount: transaction.amount,
        type: TransactionType.refund,
        status: TransactionStatus.pending,
        paymentMethod: transaction.paymentMethod,
        metadata: {
          'originalTransactionId': transactionId,
          'refundReason': 'User requested refund',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.runTransaction((firestoreTransaction) async {
        // Create refund record
        firestoreTransaction.set(refundRef, refund.toJson());

        // Update original transaction status
        firestoreTransaction.update(
          _transactionsCollection.doc(transactionId),
          {
            'status': TransactionStatus.refunded.name,
            'refundTransactionId': refundRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Remove from user's purchases
        firestoreTransaction.update(
          _usersCollection.doc(currentUser.uid),
          {
            'purchases': FieldValue.arrayRemove([transaction.experienceId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Decrement experience sales count
        firestoreTransaction.update(
          _experiencesCollection.doc(transaction.experienceId!),
          {
            'salesCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      });

      // Process actual refund through payment provider
      final refundResult = await _processRefund(
        originalTransaction: transaction,
        refundAmount: transaction.amount,
      );

      return refundResult.fold(
        (failure) async {
          await refundRef.update({
            'status': TransactionStatus.failed.name,
            'errorMessage': failure.message,
          });
          return Left(failure);
        },
        (success) async {
          await refundRef.update({
            'status': TransactionStatus.completed.name,
            'completedAt': FieldValue.serverTimestamp(),
          });
          return Right(refund.copyWith(status: TransactionStatus.completed));
        },
      );
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to process refund: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error during refund: $e'),
      );
    }
  }

  // Helper Methods

  Map<String, double> _calculateRevenueSplit({
    required double amount,
    String? referralCode,
  }) {
    // Platform fee: 20%
    // Creator earnings: 80% (or 70% if referral)
    // Referral bonus: 10% (if referral code provided)

    final platformFee = amount * 0.20;
    double creatorEarnings = amount * 0.80;
    double? referralBonus;

    if (referralCode != null) {
      creatorEarnings = amount * 0.70;
      referralBonus = amount * 0.10;
    }

    return {
      'platform': platformFee,
      'creator': creatorEarnings,
      if (referralBonus != null) 'referral': referralBonus,
      'total': amount,
    };
  }

  Future<Either<AppException, void>> _processPayment({
    required Transaction transaction,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      // This would integrate with actual payment providers
      // For now, simulate successful payment
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Implement actual payment processing
      // - Stripe for card payments
      // - Solana Pay for crypto
      // - TON Connect for TON payments

      return const Right(null);
    } catch (e) {
      return Left(
        PaymentException(message: 'Payment processing failed: $e'),
      );
    }
  }

  Future<Either<AppException, void>> _processWithdrawalPayment({
    required Transaction transaction,
    required PaymentMethod paymentMethod,
    required Map<String, dynamic> withdrawalDetails,
  }) async {
    try {
      // This would integrate with actual payout providers
      // For now, simulate successful withdrawal
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Implement actual withdrawal processing
      // - Bank transfer
      // - Crypto wallet transfer
      // - PayPal

      return const Right(null);
    } catch (e) {
      return Left(
        PaymentException(message: 'Withdrawal processing failed: $e'),
      );
    }
  }

  Future<Either<AppException, void>> _processRefund({
    required Transaction originalTransaction,
    required double refundAmount,
  }) async {
    try {
      // This would integrate with actual refund processing
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Implement actual refund through payment provider

      return const Right(null);
    } catch (e) {
      return Left(
        PaymentException(message: 'Refund processing failed: $e'),
      );
    }
  }

  Future<void> _updateSellerEarnings({
    required String sellerId,
    required double amount,
  }) async {
    await _usersCollection.doc(sellerId).update({
      'earnings': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _processReferralBonus({
    required String referralCode,
    required double amount,
    required String transactionId,
  }) async {
    try {
      // Find referrer by referral code
      final referrerQuery = await _usersCollection
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) return;

      final referrerId = referrerQuery.docs.first.id;

      // Create referral bonus transaction
      final bonusRef = _transactionsCollection.doc();
      await bonusRef.set({
        'userId': referrerId,
        'amount': amount,
        'type': TransactionType.referralBonus.name,
        'status': TransactionStatus.completed.name,
        'paymentMethod': PaymentMethod.platformCredit.name,
        'metadata': {
          'referredTransactionId': transactionId,
          'referralCode': referralCode,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update referrer's earnings
      await _usersCollection.doc(referrerId).update({
        'earnings': FieldValue.increment(amount),
        'referralEarnings': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the main transaction
      print('Failed to process referral bonus: $e');
    }
  }
}

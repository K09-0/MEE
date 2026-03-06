import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../domain/entities/transaction.dart';

/// Payment Service
/// 
/// Сервис для обработки платежей
/// Поддерживает Stripe (фиат) и криптовалюты (Solana, TON)
class PaymentService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  // Collection reference
  CollectionReference get _transactionsCollection => 
      _firestore.collection('transactions');

  PaymentService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  /// Initialize Stripe
  static Future<void> initializeStripe(String publishableKey) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  // ==================== STRIPE PAYMENTS ====================

  /// Create payment intent for experience purchase
  Future<PaymentIntentResult> createPaymentIntent({
    required String experienceId,
    required double amount,
    required String currency,
    required String buyerId,
  }) async {
    try {
      AppLogger.i('Creating payment intent for $experienceId');

      // Call Cloud Function to create payment intent
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'experienceId': experienceId,
        'amount': (amount * 100).toInt(), // Convert to cents
        'currency': currency.toLowerCase(),
        'buyerId': buyerId,
      });

      final data = result.data as Map<String, dynamic>;
      
      return PaymentIntentResult(
        clientSecret: data['clientSecret'] as String,
        paymentIntentId: data['paymentIntentId'] as String,
        amount: amount,
        currency: currency,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Create payment intent error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Failed to create payment: $e');
    }
  }

  /// Present payment sheet
  Future<bool> presentPaymentSheet(String clientSecret) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MEE - MicroExperiential Engine',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFB829F7),
              background: Color(0xFF0A0A0F),
              componentBackground: Color(0xFF1A1A24),
              componentBorder: Color(0xFF3D3D4D),
              primaryText: Colors.white,
              secondaryText: Color(0xFFB3B3B3),
              placeholderText: Color(0xFF666666),
            ),
            shapes: PaymentSheetShape(
              borderWidth: 1,
              shadow: PaymentSheetShadowParams(color: Colors.transparent),
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        AppLogger.i('Payment cancelled by user');
        return false;
      }
      AppLogger.e('Payment sheet error', error: e);
      throw PaymentException(message: 'Payment failed: ${e.error.localizedMessage}');
    } catch (e, stackTrace) {
      AppLogger.e('Present payment sheet error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Payment failed: $e');
    }
  }

  /// Confirm payment (after successful payment sheet)
  Future<Transaction> confirmPayment({
    required String transactionId,
    required String paymentIntentId,
  }) async {
    try {
      AppLogger.i('Confirming payment: $paymentIntentId');

      final callable = _functions.httpsCallable('confirmPayment');
      final result = await callable.call({
        'transactionId': transactionId,
        'paymentIntentId': paymentIntentId,
      });

      final data = result.data as Map<String, dynamic>;
      
      return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.e('Confirm payment error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Failed to confirm payment: $e');
    }
  }

  // ==================== SOLANA PAY ====================

  /// Create Solana Pay transaction
  Future<SolanaPayResult> createSolanaPayment({
    required String experienceId,
    required double amount, // in SOL
    required String buyerId,
    required String sellerWalletAddress,
  }) async {
    try {
      AppLogger.i('Creating Solana payment for $experienceId');

      final callable = _functions.httpsCallable('createSolanaPayment');
      final result = await callable.call({
        'experienceId': experienceId,
        'amount': amount,
        'buyerId': buyerId,
        'sellerWalletAddress': sellerWalletAddress,
      });

      final data = result.data as Map<String, dynamic>;
      
      return SolanaPayResult(
        transactionId: data['transactionId'] as String,
        solanaPayUrl: data['solanaPayUrl'] as String,
        recipient: sellerWalletAddress,
        amount: amount,
        reference: data['reference'] as String,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Create Solana payment error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Failed to create Solana payment: $e');
    }
  }

  /// Verify Solana transaction
  Future<bool> verifySolanaTransaction(String signature) async {
    try {
      final callable = _functions.httpsCallable('verifySolanaTransaction');
      final result = await callable.call({'signature': signature});
      
      return result.data['verified'] as bool? ?? false;
    } catch (e, stackTrace) {
      AppLogger.e('Verify Solana transaction error', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ==================== TON CONNECT ====================

  /// Create TON payment
  Future<TonPayResult> createTonPayment({
    required String experienceId,
    required double amount, // in TON
    required String buyerId,
    required String sellerWalletAddress,
  }) async {
    try {
      AppLogger.i('Creating TON payment for $experienceId');

      final callable = _functions.httpsCallable('createTonPayment');
      final result = await callable.call({
        'experienceId': experienceId,
        'amount': amount,
        'buyerId': buyerId,
        'sellerWalletAddress': sellerWalletAddress,
      });

      final data = result.data as Map<String, dynamic>;
      
      return TonPayResult(
        transactionId: data['transactionId'] as String,
        tonConnectUrl: data['tonConnectUrl'] as String,
        recipient: sellerWalletAddress,
        amount: amount,
        comment: data['comment'] as String,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Create TON payment error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Failed to create TON payment: $e');
    }
  }

  // ==================== WALLET & WITHDRAWAL ====================

  /// Get wallet balance
  Future<WalletBalance> getWalletBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      
      if (!doc.exists) {
        return WalletBalance(
          userId: userId,
          updatedAt: DateTime.now(),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return WalletBalance(
        userId: userId,
        fiatBalance: (data['fiatBalance'] as num?)?.toDouble() ?? 0.0,
        solBalance: (data['solBalance'] as num?)?.toDouble() ?? 0.0,
        tonBalance: (data['tonBalance'] as num?)?.toDouble() ?? 0.0,
        pendingBalance: (data['pendingBalance'] as num?)?.toDouble() ?? 0.0,
        totalEarned: (data['totalEarned'] as num?)?.toDouble() ?? 0.0,
        totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Get wallet balance error', error: e, stackTrace: stackTrace);
      throw UnknownException(message: 'Failed to get wallet balance: $e');
    }
  }

  /// Stream wallet balance
  Stream<WalletBalance> walletBalanceStream(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return WalletBalance(
          userId: userId,
          updatedAt: DateTime.now(),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return WalletBalance(
        userId: userId,
        fiatBalance: (data['fiatBalance'] as num?)?.toDouble() ?? 0.0,
        solBalance: (data['solBalance'] as num?)?.toDouble() ?? 0.0,
        tonBalance: (data['tonBalance'] as num?)?.toDouble() ?? 0.0,
        pendingBalance: (data['pendingBalance'] as num?)?.toDouble() ?? 0.0,
        totalEarned: (data['totalEarned'] as num?)?.toDouble() ?? 0.0,
        totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      );
    });
  }

  /// Request withdrawal
  Future<Transaction> requestWithdrawal({
    required String userId,
    required double amount,
    required Currency currency,
    required PaymentMethod method,
    required Map<String, dynamic> withdrawalDetails,
  }) async {
    try {
      AppLogger.i('Requesting withdrawal: $amount $currency');

      final callable = _functions.httpsCallable('requestWithdrawal');
      final result = await callable.call({
        'userId': userId,
        'amount': amount,
        'currency': currency.name,
        'method': method.name,
        'withdrawalDetails': withdrawalDetails,
      });

      final data = result.data as Map<String, dynamic>;
      
      return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.e('Request withdrawal error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Failed to request withdrawal: $e');
    }
  }

  /// Add funds to wallet
  Future<Transaction> addFunds({
    required String userId,
    required double amount,
    required PaymentMethod method,
  }) async {
    try {
      AppLogger.i('Adding funds: $amount');

      final callable = _functions.httpsCallable('addFunds');
      final result = await callable.call({
        'userId': userId,
        'amount': amount,
        'method': method.name,
      });

      final data = result.data as Map<String, dynamic>;
      
      return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.e('Add funds error', error: e, stackTrace: stackTrace);
      throw PaymentException(message: 'Failed to add funds: $e');
    }
  }

  /// Get transaction history
  Future<List<Transaction>> getTransactionHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = await _transactionsCollection
          .where('buyerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Transaction.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Get transaction history error', error: e, stackTrace: stackTrace);
      throw UnknownException(message: 'Failed to get transaction history: $e');
    }
  }

  /// Stream transaction updates
  Stream<Transaction?> transactionStream(String transactionId) {
    return _transactionsCollection
        .doc(transactionId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      return Transaction.fromJson({...data, 'id': doc.id});
    });
  }
}

/// Payment Intent Result
class PaymentIntentResult {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;
  final String currency;

  const PaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
  });
}

/// Solana Pay Result
class SolanaPayResult {
  final String transactionId;
  final String solanaPayUrl;
  final String recipient;
  final double amount;
  final String reference;

  const SolanaPayResult({
    required this.transactionId,
    required this.solanaPayUrl,
    required this.recipient,
    required this.amount,
    required this.reference,
  });
}

/// TON Pay Result
class TonPayResult {
  final String transactionId;
  final String tonConnectUrl;
  final String recipient;
  final double amount;
  final String comment;

  const TonPayResult({
    required this.transactionId,
    required this.tonConnectUrl,
    required this.recipient,
    required this.amount,
    required this.comment,
  });
}

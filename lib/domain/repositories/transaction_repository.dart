import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../entities/transaction.dart';

/// Transaction Repository Interface
/// 
/// Определяет контракт для финансовых операций
abstract class TransactionRepository {
  /// Get transaction by ID
  Future<Either<AppException, Transaction>> getTransaction(String id);

  /// Get user's transactions
  Future<Either<AppException, List<Transaction>>> getUserTransactions(
    String userId, {
    TransactionFilter? filter,
    int page = 1,
    int limit = 20,
  });

  /// Get wallet balance
  Future<Either<AppException, WalletBalance>> getWalletBalance(String userId);

  /// Stream of wallet balance updates
  Stream<WalletBalance> walletBalanceStream(String userId);

  /// Create purchase transaction
  Future<Either<AppException, Transaction>> createPurchase({
    required String experienceId,
    required double amount,
    required Currency currency,
    required PaymentMethod paymentMethod,
  });

  /// Process payment
  Future<Either<AppException, Transaction>> processPayment({
    required String transactionId,
    required Map<String, dynamic> paymentData,
  });

  /// Confirm payment (webhook handler)
  Future<Either<AppException, Transaction>> confirmPayment({
    required String transactionId,
    required String paymentIntentId,
  });

  /// Create withdrawal
  Future<Either<AppException, Transaction>> createWithdrawal({
    required double amount,
    required Currency currency,
    required PaymentMethod paymentMethod,
    required Map<String, dynamic> withdrawalDetails,
  });

  /// Process withdrawal
  Future<Either<AppException, Transaction>> processWithdrawal(String transactionId);

  /// Cancel transaction
  Future<Either<AppException, Transaction>> cancelTransaction(String transactionId);

  /// Refund transaction
  Future<Either<AppException, Transaction>> refundTransaction({
    required String transactionId,
    double? amount,
    String? reason,
  });

  /// Get referral earnings
  Future<Either<AppException, double>> getReferralEarnings(String userId);

  /// Get referral stats
  Future<Either<AppException, ReferralStats>> getReferralStats(String userId);

  /// Add funds to wallet (deposit)
  Future<Either<AppException, Transaction>> addFunds({
    required double amount,
    required PaymentMethod paymentMethod,
  });

  /// Convert currency
  Future<Either<AppException, double>> convertCurrency({
    required double amount,
    required Currency from,
    required Currency to,
  });

  /// Get transaction statistics
  Future<Either<AppException, TransactionStats>> getTransactionStats(String userId);

  /// Verify blockchain transaction
  Future<Either<AppException, bool>> verifyBlockchainTransaction(
    String txHash, {
    required Currency currency,
  });

  /// Stream of transaction updates
  Stream<Transaction?> transactionStream(String transactionId);
}

/// Referral Statistics
class ReferralStats {
  final int totalReferrals;
  final int activeReferrals;
  final double totalEarnings;
  final double currentMonthEarnings;
  final List<Referral> referrals;

  const ReferralStats({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalEarnings,
    required this.currentMonthEarnings,
    required this.referrals,
  });
}

/// Referral
class Referral {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime joinedAt;
  final double totalSpent;
  final double earningsFromReferral;

  const Referral({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.joinedAt,
    required this.totalSpent,
    required this.earningsFromReferral,
  });
}

/// Transaction Statistics
class TransactionStats {
  final double totalSpent;
  final double totalEarned;
  final int totalPurchases;
  final int totalSales;
  final double averagePurchaseAmount;
  final double averageSaleAmount;
  final Map<String, double> monthlyEarnings;
  final Map<String, double> monthlySpending;

  const TransactionStats({
    required this.totalSpent,
    required this.totalEarned,
    required this.totalPurchases,
    required this.totalSales,
    required this.averagePurchaseAmount,
    required this.averageSaleAmount,
    required this.monthlyEarnings,
    required this.monthlySpending,
  });

  /// Net profit (earned - spent)
  double get netProfit => totalEarned - totalSpent;
}

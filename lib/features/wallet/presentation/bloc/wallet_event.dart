part of 'wallet_bloc.dart';

/// Wallet Events
/// 
/// Все события, связанные с кошельком
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Load wallet balance
class LoadWalletBalanceRequested extends WalletEvent {
  final String userId;

  const LoadWalletBalanceRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load transaction history
class LoadTransactionHistoryRequested extends WalletEvent {
  final String userId;
  final TransactionFilter? filter;
  final int page;
  final int limit;

  const LoadTransactionHistoryRequested({
    required this.userId,
    this.filter,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, filter, page, limit];
}

/// Add funds to wallet
class AddFundsRequested extends WalletEvent {
  final String userId;
  final double amount;
  final PaymentMethod paymentMethod;

  const AddFundsRequested({
    required this.userId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [userId, amount, paymentMethod];
}

/// Withdraw funds
class WithdrawFundsRequested extends WalletEvent {
  final String userId;
  final double amount;
  final Currency currency;
  final PaymentMethod paymentMethod;
  final Map<String, dynamic> withdrawalDetails;

  const WithdrawFundsRequested({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.withdrawalDetails,
  });

  @override
  List<Object?> get props => [
    userId,
    amount,
    currency,
    paymentMethod,
    withdrawalDetails,
  ];
}

/// Purchase experience
class PurchaseExperienceRequested extends WalletEvent {
  final String userId;
  final String experienceId;
  final double amount;
  final Currency currency;
  final PaymentMethod paymentMethod;

  const PurchaseExperienceRequested({
    required this.userId,
    required this.experienceId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    userId,
    experienceId,
    amount,
    currency,
    paymentMethod,
  ];
}

/// Convert currency
class ConvertCurrencyRequested extends WalletEvent {
  final double amount;
  final Currency from;
  final Currency to;

  const ConvertCurrencyRequested({
    required this.amount,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [amount, from, to];
}

/// Load referral stats
class LoadReferralStatsRequested extends WalletEvent {
  final String userId;

  const LoadReferralStatsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Cancel transaction
class CancelTransactionRequested extends WalletEvent {
  final String transactionId;

  const CancelTransactionRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Refund transaction
class RefundTransactionRequested extends WalletEvent {
  final String transactionId;
  final double? amount;
  final String? reason;

  const RefundTransactionRequested({
    required this.transactionId,
    this.amount,
    this.reason,
  });

  @override
  List<Object?> get props => [transactionId, amount, reason];
}

/// Get transaction stats
class GetTransactionStatsRequested extends WalletEvent {
  final String userId;

  const GetTransactionStatsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

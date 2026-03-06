part of 'wallet_bloc.dart';

/// Wallet Status
/// 
/// Возможные состояния кошелька
enum WalletStatus {
  initial,
  loading,
  loaded,
  processing,
  success,
  purchaseSuccess,
  error,
}

/// Wallet State
/// 
/// Состояние кошелька в приложении
class WalletState extends Equatable {
  final WalletStatus status;
  final WalletBalance? balance;
  final List<Transaction> transactions;
  final Transaction? lastTransaction;
  final ReferralStats? referralStats;
  final TransactionStats? transactionStats;
  final double? convertedAmount;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.balance,
    this.transactions = const [],
    this.lastTransaction,
    this.referralStats,
    this.transactionStats,
    this.convertedAmount,
    this.errorMessage,
  });

  /// Initial state
  factory WalletState.initial() => const WalletState();

  /// Loading state
  factory WalletState.loading() => const WalletState(
    status: WalletStatus.loading,
  );

  /// Loaded state
  factory WalletState.loaded(WalletBalance balance) => WalletState(
    status: WalletStatus.loaded,
    balance: balance,
  );

  /// Error state
  factory WalletState.error(String message) => WalletState(
    status: WalletStatus.error,
    errorMessage: message,
  );

  /// Check if loading
  bool get isLoading => status == WalletStatus.loading;

  /// Check if processing
  bool get isProcessing => status == WalletStatus.processing;

  /// Check if loaded
  bool get isLoaded => status == WalletStatus.loaded;

  /// Check if success
  bool get isSuccess => status == WalletStatus.success;

  /// Check if purchase success
  bool get isPurchaseSuccess => status == WalletStatus.purchaseSuccess;

  /// Check if has error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Get fiat balance
  double get fiatBalance => balance?.fiatBalance ?? 0.0;

  /// Get crypto balances
  double get solBalance => balance?.solBalance ?? 0.0;
  double get tonBalance => balance?.tonBalance ?? 0.0;

  /// Get total balance in USD
  double get totalBalance => balance?.totalUsdBalance ?? 0.0;

  /// Get pending balance
  double get pendingBalance => balance?.pendingBalance ?? 0.0;

  /// Get total earned
  double get totalEarned => balance?.totalEarned ?? 0.0;

  /// Get total spent
  double get totalSpent => balance?.totalSpent ?? 0.0;

  /// Check if has sufficient balance
  bool hasSufficientBalance(double amount, Currency currency) {
    return balance?.hasSufficientBalance(amount, currency) ?? false;
  }

  /// Get income transactions
  List<Transaction> get incomeTransactions => transactions
    .where((t) => t.type.isIncoming)
    .toList();

  /// Get expense transactions
  List<Transaction> get expenseTransactions => transactions
    .where((t) => t.type.isOutgoing)
    .toList();

  /// Get completed transactions
  List<Transaction> get completedTransactions => transactions
    .where((t) => t.isCompleted)
    .toList();

  /// Get pending transactions
  List<Transaction> get pendingTransactions => transactions
    .where((t) => t.isPending)
    .toList();

  /// Copy with
  WalletState copyWith({
    WalletStatus? status,
    WalletBalance? balance,
    List<Transaction>? transactions,
    Transaction? lastTransaction,
    ReferralStats? referralStats,
    TransactionStats? transactionStats,
    double? convertedAmount,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      lastTransaction: lastTransaction ?? this.lastTransaction,
      referralStats: referralStats ?? this.referralStats,
      transactionStats: transactionStats ?? this.transactionStats,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    balance,
    transactions,
    lastTransaction,
    referralStats,
    transactionStats,
    convertedAmount,
    errorMessage,
  ];

  @override
  String toString() {
    return 'WalletState(status: $status, balance: ${balance?.fiatBalance}, transactions: ${transactions.length})';
  }
}

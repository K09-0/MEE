import 'package:equatable/equatable.dart';

import 'experience.dart';
import 'user.dart';

/// Transaction Entity
/// 
/// Представляет финансовую транзакцию в системе MEE
/// Покупки, продажи, выводы средств, реферальные бонусы
class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final String? buyerId;
  final User? buyer;
  final String? sellerId;
  final User? seller;
  final String? experienceId;
  final Experience? experience;
  final double amount;
  final double platformFee;
  final double netAmount;
  final Currency currency;
  final PaymentMethod paymentMethod;
  final String? paymentIntentId; // Stripe
  final String? blockchainTxHash; // Crypto
  final String? referralCode; // If referral bonus
  final String? description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? failureReason;
  final DateTime? refundedAt;
  final double? refundedAmount;

  const Transaction({
    required this.id,
    required this.type,
    this.status = TransactionStatus.pending,
    this.buyerId,
    this.buyer,
    this.sellerId,
    this.seller,
    this.experienceId,
    this.experience,
    required this.amount,
    this.platformFee = 0.0,
    this.netAmount = 0.0,
    this.currency = Currency.usd,
    required this.paymentMethod,
    this.paymentIntentId,
    this.blockchainTxHash,
    this.referralCode,
    this.description,
    this.metadata = const {},
    required this.createdAt,
    this.completedAt,
    this.failedAt,
    this.failureReason,
    this.refundedAt,
    this.refundedAmount,
  });

  /// Empty transaction
  factory Transaction.empty() => Transaction(
    id: '',
    type: TransactionType.purchase,
    amount: 0.0,
    paymentMethod: PaymentMethod.stripe,
    createdAt: DateTime.now(),
  );

  /// Create purchase transaction
  factory Transaction.purchase({
    required String id,
    required String buyerId,
    required String sellerId,
    required String experienceId,
    required double amount,
    required Currency currency,
    required PaymentMethod paymentMethod,
  }) {
    final platformFee = amount * 0.20; // 20% platform fee
    final netAmount = amount * 0.80; // 80% to seller
    
    return Transaction(
      id: id,
      type: TransactionType.purchase,
      buyerId: buyerId,
      sellerId: sellerId,
      experienceId: experienceId,
      amount: amount,
      platformFee: platformFee,
      netAmount: netAmount,
      currency: currency,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
  }

  /// Create withdrawal transaction
  factory Transaction.withdrawal({
    required String id,
    required String sellerId,
    required double amount,
    required Currency currency,
    required PaymentMethod paymentMethod,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.withdrawal,
      sellerId: sellerId,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
  }

  /// Create referral bonus transaction
  factory Transaction.referralBonus({
    required String id,
    required String sellerId,
    required double amount,
    required String referralCode,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.referralBonus,
      sellerId: sellerId,
      amount: amount,
      netAmount: amount, // No fee for referral bonuses
      currency: Currency.usd,
      paymentMethod: PaymentMethod.internal,
      referralCode: referralCode,
      description: 'Referral bonus',
      createdAt: DateTime.now(),
    );
  }

  /// Check if transaction is pending
  bool get isPending => status == TransactionStatus.pending;

  /// Check if transaction is completed
  bool get isCompleted => status == TransactionStatus.completed;

  /// Check if transaction is failed
  bool get isFailed => status == TransactionStatus.failed;

  /// Check if transaction is refunded
  bool get isRefunded => status == TransactionStatus.refunded;

  /// Check if transaction can be refunded
  bool get canBeRefunded => 
    isCompleted && 
    refundedAt == null && 
    type == TransactionType.purchase;

  /// Get formatted amount
  String get formattedAmount {
    switch (currency) {
      case Currency.usd:
        return '\$${amount.toStringAsFixed(2)}';
      case Currency.eur:
        return '€${amount.toStringAsFixed(2)}';
      case Currency.gbp:
        return '£${amount.toStringAsFixed(2)}';
      case Currency.sol:
        return '${amount.toStringAsFixed(4)} SOL';
      case Currency.ton:
        return '${amount.toStringAsFixed(4)} TON';
    }
  }

  /// Get formatted net amount (for sellers)
  String get formattedNetAmount {
    switch (currency) {
      case Currency.usd:
        return '\$${netAmount.toStringAsFixed(2)}';
      case Currency.eur:
        return '€${netAmount.toStringAsFixed(2)}';
      case Currency.gbp:
        return '£${netAmount.toStringAsFixed(2)}';
      case Currency.sol:
        return '${netAmount.toStringAsFixed(4)} SOL';
      case Currency.ton:
        return '${netAmount.toStringAsFixed(4)} TON';
    }
  }

  /// Get transaction duration
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  /// Mark as completed
  Transaction markCompleted({String? blockchainTxHash}) {
    return copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
      blockchainTxHash: blockchainTxHash ?? this.blockchainTxHash,
    );
  }

  /// Mark as failed
  Transaction markFailed(String reason) {
    return copyWith(
      status: TransactionStatus.failed,
      failedAt: DateTime.now(),
      failureReason: reason,
    );
  }

  /// Mark as refunded
  Transaction markRefunded(double amount) {
    return copyWith(
      status: TransactionStatus.refunded,
      refundedAt: DateTime.now(),
      refundedAmount: amount,
    );
  }

  /// Copy with
  Transaction copyWith({
    String? id,
    TransactionType? type,
    TransactionStatus? status,
    String? buyerId,
    User? buyer,
    String? sellerId,
    User? seller,
    String? experienceId,
    Experience? experience,
    double? amount,
    double? platformFee,
    double? netAmount,
    Currency? currency,
    PaymentMethod? paymentMethod,
    String? paymentIntentId,
    String? blockchainTxHash,
    String? referralCode,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? failedAt,
    String? failureReason,
    DateTime? refundedAt,
    double? refundedAmount,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      buyerId: buyerId ?? this.buyerId,
      buyer: buyer ?? this.buyer,
      sellerId: sellerId ?? this.sellerId,
      seller: seller ?? this.seller,
      experienceId: experienceId ?? this.experienceId,
      experience: experience ?? this.experience,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      blockchainTxHash: blockchainTxHash ?? this.blockchainTxHash,
      referralCode: referralCode ?? this.referralCode,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failedAt: failedAt ?? this.failedAt,
      failureReason: failureReason ?? this.failureReason,
      refundedAt: refundedAt ?? this.refundedAt,
      refundedAmount: refundedAmount ?? this.refundedAmount,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'experienceId': experienceId,
      'amount': amount,
      'platformFee': platformFee,
      'netAmount': netAmount,
      'currency': currency.name,
      'paymentMethod': paymentMethod.name,
      'paymentIntentId': paymentIntentId,
      'blockchainTxHash': blockchainTxHash,
      'referralCode': referralCode,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failedAt': failedAt?.toIso8601String(),
      'failureReason': failureReason,
      'refundedAt': refundedAt?.toIso8601String(),
      'refundedAmount': refundedAmount,
    };
  }

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.purchase,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      buyerId: json['buyerId'] as String?,
      buyer: json['buyer'] != null
          ? User.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      sellerId: json['sellerId'] as String?,
      seller: json['seller'] != null
          ? User.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      experienceId: json['experienceId'] as String?,
      experience: json['experience'] != null
          ? Experience.fromJson(json['experience'] as Map<String, dynamic>)
          : null,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      currency: Currency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => Currency.usd,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.stripe,
      ),
      paymentIntentId: json['paymentIntentId'] as String?,
      blockchainTxHash: json['blockchainTxHash'] as String?,
      referralCode: json['referralCode'] as String?,
      description: json['description'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failedAt: json['failedAt'] != null
          ? DateTime.parse(json['failedAt'] as String)
          : null,
      failureReason: json['failureReason'] as String?,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'] as String)
          : null,
      refundedAmount: (json['refundedAmount'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    buyerId,
    buyer,
    sellerId,
    seller,
    experienceId,
    experience,
    amount,
    platformFee,
    netAmount,
    currency,
    paymentMethod,
    paymentIntentId,
    blockchainTxHash,
    referralCode,
    description,
    metadata,
    createdAt,
    completedAt,
    failedAt,
    failureReason,
    refundedAt,
    refundedAmount,
  ];
}

/// Transaction Type
enum TransactionType {
  purchase,       // Buy experience
  sale,          // Sell experience (for seller)
  withdrawal,    // Withdraw earnings
  deposit,       // Add funds
  referralBonus, // Referral reward
  subscription,  // Subscription payment
  refund,        // Refund
  fee,           // Platform fee
}

/// Extension for TransactionType
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.referralBonus:
        return 'Referral Bonus';
      case TransactionType.subscription:
        return 'Subscription';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.fee:
        return 'Platform Fee';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.purchase:
        return '🛒';
      case TransactionType.sale:
        return '💰';
      case TransactionType.withdrawal:
        return '🏧';
      case TransactionType.deposit:
        return '💵';
      case TransactionType.referralBonus:
        return '🎁';
      case TransactionType.subscription:
        return '⭐';
      case TransactionType.refund:
        return '↩️';
      case TransactionType.fee:
        return '📊';
    }
  }

  bool get isIncoming {
    switch (this) {
      case TransactionType.sale:
      case TransactionType.referralBonus:
      case TransactionType.refund:
        return true;
      default:
        return false;
    }
  }

  bool get isOutgoing {
    switch (this) {
      case TransactionType.purchase:
      case TransactionType.withdrawal:
      case TransactionType.deposit:
      case TransactionType.subscription:
      case TransactionType.fee:
        return true;
      default:
        return false;
    }
  }
}

/// Transaction Status
enum TransactionStatus {
  pending,      // Awaiting confirmation
  processing,   // Being processed
  completed,    // Successful
  failed,       // Failed
  cancelled,    // Cancelled by user
  refunded,     // Refunded
  disputed,     // Under dispute
}

/// Extension for TransactionStatus
extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.refunded:
        return 'Refunded';
      case TransactionStatus.disputed:
        return 'Disputed';
    }
  }

  String get color {
    switch (this) {
      case TransactionStatus.pending:
        return 'orange';
      case TransactionStatus.processing:
        return 'blue';
      case TransactionStatus.completed:
        return 'green';
      case TransactionStatus.failed:
        return 'red';
      case TransactionStatus.cancelled:
        return 'grey';
      case TransactionStatus.refunded:
        return 'purple';
      case TransactionStatus.disputed:
        return 'yellow';
    }
  }
}

/// Payment Method
enum PaymentMethod {
  stripe,
  solanaPay,
  tonConnect,
  applePay,
  googlePay,
  internal, // For internal transfers (referrals, etc.)
}

/// Extension for PaymentMethod
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.stripe:
        return 'Credit Card';
      case PaymentMethod.solanaPay:
        return 'Solana Pay';
      case PaymentMethod.tonConnect:
        return 'TON Connect';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.internal:
        return 'Internal Transfer';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.stripe:
        return '💳';
      case PaymentMethod.solanaPay:
        return '◎';
      case PaymentMethod.tonConnect:
        return '💎';
      case PaymentMethod.applePay:
        return '🍎';
      case PaymentMethod.googlePay:
        return 'G';
      case PaymentMethod.internal:
        return '↔️';
    }
  }

  bool get isCrypto {
    return this == PaymentMethod.solanaPay || this == PaymentMethod.tonConnect;
  }
}

/// Transaction Filter
class TransactionFilter {
  final TransactionType? type;
  final TransactionStatus? status;
  final String? userId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minAmount;
  final double? maxAmount;
  final PaymentMethod? paymentMethod;

  const TransactionFilter({
    this.type,
    this.status,
    this.userId,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    this.paymentMethod,
  });

  /// Empty filter
  factory TransactionFilter.empty() => const TransactionFilter();

  /// Copy with
  TransactionFilter copyWith({
    TransactionType? type,
    TransactionStatus? status,
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    PaymentMethod? paymentMethod,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

/// Wallet Balance
class WalletBalance extends Equatable {
  final String userId;
  final double fiatBalance; // USD
  final double solBalance;
  final double tonBalance;
  final double pendingBalance; // Pending withdrawals
  final double totalEarned;
  final double totalSpent;
  final DateTime updatedAt;

  const WalletBalance({
    required this.userId,
    this.fiatBalance = 0.0,
    this.solBalance = 0.0,
    this.tonBalance = 0.0,
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
    required this.updatedAt,
  });

  /// Get total available balance in USD (approximate)
  double get totalUsdBalance => fiatBalance; // + crypto converted

  /// Check if has sufficient balance
  bool hasSufficientBalance(double amount, Currency currency) {
    switch (currency) {
      case Currency.usd:
      case Currency.eur:
      case Currency.gbp:
        return fiatBalance >= amount;
      case Currency.sol:
        return solBalance >= amount;
      case Currency.ton:
        return tonBalance >= amount;
    }
  }

  /// Copy with
  WalletBalance copyWith({
    String? userId,
    double? fiatBalance,
    double? solBalance,
    double? tonBalance,
    double? pendingBalance,
    double? totalEarned,
    double? totalSpent,
    DateTime? updatedAt,
  }) {
    return WalletBalance(
      userId: userId ?? this.userId,
      fiatBalance: fiatBalance ?? this.fiatBalance,
      solBalance: solBalance ?? this.solBalance,
      tonBalance: tonBalance ?? this.tonBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fiatBalance,
    solBalance,
    tonBalance,
    pendingBalance,
    totalEarned,
    totalSpent,
    updatedAt,
  ];
}

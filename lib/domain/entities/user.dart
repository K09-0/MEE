import 'package:equatable/equatable.dart';

/// User Entity
/// 
/// Представляет пользователя в системе MEE
/// Содержит все данные профиля, баланс и настройки
class User extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? walletAddress;
  final WalletType walletType;
  final double balance;
  final double totalEarned;
  final int rating;
  final String referralCode;
  final String? referredBy;
  final UserRole role;
  final UserStatus status;
  final SubscriptionTier subscription;
  final DateTime? subscriptionExpiresAt;
  final int dailyGenerationsUsed;
  final DateTime? lastGenerationDate;
  final List<String> interests;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.dateOfBirth,
    this.walletAddress,
    this.walletType = WalletType.none,
    this.balance = 0.0,
    this.totalEarned = 0.0,
    this.rating = 0,
    required this.referralCode,
    this.referredBy,
    this.role = UserRole.user,
    this.status = UserStatus.active,
    this.subscription = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    this.dailyGenerationsUsed = 0,
    this.lastGenerationDate,
    this.interests = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// Empty user (for initial state)
  factory User.empty() => User(
    id: '',
    email: '',
    referralCode: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// Check if user is empty
  bool get isEmpty => id.isEmpty;

  /// Check if user is authenticated
  bool get isAuthenticated => id.isNotEmpty;

  /// Check if user has connected wallet
  bool get hasWallet => walletAddress != null && walletAddress!.isNotEmpty;

  /// Check if user is creator (has created at least one experience)
  bool get isCreator => totalEarned > 0;

  /// Check if user has Pro subscription
  bool get isPro => subscription == SubscriptionTier.pro ||
                    subscription == SubscriptionTier.enterprise;

  /// Check if user can generate today
  bool get canGenerateToday {
    if (isPro) return true;
    if (lastGenerationDate == null) return true;
    
    final now = DateTime.now();
    final lastDate = lastGenerationDate!;
    
    // Reset if it's a new day
    if (now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day) {
      return true;
    }
    
    return dailyGenerationsUsed < 3; // Free tier limit
  }

  /// Get remaining generations today
  int get remainingGenerationsToday {
    if (isPro) return 50;
    if (!canGenerateToday) return 0;
    return 3 - dailyGenerationsUsed;
  }

  /// Get display name (username or email prefix)
  String get displayNameOrUsername => 
    displayName ?? username ?? email.split('@').first;

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user is adult (18+)
  bool get isAdult {
    final userAge = age;
    return userAge != null && userAge >= 18;
  }

  /// Copy with method
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? walletAddress,
    WalletType? walletType,
    double? balance,
    double? totalEarned,
    int? rating,
    String? referralCode,
    String? referredBy,
    UserRole? role,
    UserStatus? status,
    SubscriptionTier? subscription,
    DateTime? subscriptionExpiresAt,
    int? dailyGenerationsUsed,
    DateTime? lastGenerationDate,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      walletAddress: walletAddress ?? this.walletAddress,
      walletType: walletType ?? this.walletType,
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      rating: rating ?? this.rating,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      role: role ?? this.role,
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      dailyGenerationsUsed: dailyGenerationsUsed ?? this.dailyGenerationsUsed,
      lastGenerationDate: lastGenerationDate ?? this.lastGenerationDate,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'walletAddress': walletAddress,
      'walletType': walletType.name,
      'balance': balance,
      'totalEarned': totalEarned,
      'rating': rating,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'role': role.name,
      'status': status.name,
      'subscription': subscription.name,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'dailyGenerationsUsed': dailyGenerationsUsed,
      'lastGenerationDate': lastGenerationDate?.toIso8601String(),
      'interests': interests,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      walletAddress: json['walletAddress'] as String?,
      walletType: WalletType.values.firstWhere(
        (e) => e.name == json['walletType'],
        orElse: () => WalletType.none,
      ),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      rating: json['rating'] as int? ?? 0,
      referralCode: json['referralCode'] as String,
      referredBy: json['referredBy'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      subscription: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['subscription'],
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      dailyGenerationsUsed: json['dailyGenerationsUsed'] as int? ?? 0,
      lastGenerationDate: json['lastGenerationDate'] != null
          ? DateTime.parse(json['lastGenerationDate'] as String)
          : null,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      preferences: (json['preferences'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    displayName,
    avatarUrl,
    bio,
    dateOfBirth,
    walletAddress,
    walletType,
    balance,
    totalEarned,
    rating,
    referralCode,
    referredBy,
    role,
    status,
    subscription,
    subscriptionExpiresAt,
    dailyGenerationsUsed,
    lastGenerationDate,
    interests,
    preferences,
    createdAt,
    updatedAt,
    lastLoginAt,
  ];
}

/// Wallet Type
enum WalletType {
  none,
  phantom,    // Solana
  tonkeeper,  // TON
  metamask,   // Ethereum (future)
  walletConnect, // Multi-chain (future)
}

/// User Role
enum UserRole {
  user,
  creator,
  moderator,
  admin,
  superAdmin,
}

/// User Status
enum UserStatus {
  active,
  inactive,
  suspended,
  banned,
  pendingVerification,
}

/// Subscription Tier
enum SubscriptionTier {
  free,
  pro,
  enterprise,
}

/// Extension for SubscriptionTier
extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.enterprise:
        return 'Enterprise';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.pro:
        return 9.99;
      case SubscriptionTier.enterprise:
        return 49.99;
    }
  }

  int get dailyGenerations {
    switch (this) {
      case SubscriptionTier.free:
        return 3;
      case SubscriptionTier.pro:
        return 50;
      case SubscriptionTier.enterprise:
        return 200;
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          '3 AI generations per day',
          'Basic templates',
          'Standard support',
        ];
      case SubscriptionTier.pro:
        return [
          '50 AI generations per day',
          'Premium templates',
          'Priority support',
          'Advanced analytics',
          'Custom branding',
        ];
      case SubscriptionTier.enterprise:
        return [
          'Unlimited AI generations',
          'All templates',
          '24/7 dedicated support',
          'Full analytics suite',
          'White-label option',
          'API access',
        ];
    }
  }
}

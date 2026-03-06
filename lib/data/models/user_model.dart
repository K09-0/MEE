import '../../domain/entities/user.dart';

/// User Model (Firestore)
/// 
/// Модель для работы с Firestore
/// Содержит методы сериализации/десериализации
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? walletAddress;
  final String walletType;
  final double balance;
  final double totalEarned;
  final int rating;
  final String referralCode;
  final String? referredBy;
  final String role;
  final String status;
  final String subscription;
  final DateTime? subscriptionExpiresAt;
  final int dailyGenerationsUsed;
  final DateTime? lastGenerationDate;
  final List<String> interests;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.dateOfBirth,
    this.walletAddress,
    this.walletType = 'none',
    this.balance = 0.0,
    this.totalEarned = 0.0,
    this.rating = 0,
    required this.referralCode,
    this.referredBy,
    this.role = 'user',
    this.status = 'active',
    this.subscription = 'free',
    this.subscriptionExpiresAt,
    this.dailyGenerationsUsed = 0,
    this.lastGenerationDate,
    this.interests = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      walletAddress: json['walletAddress'] as String?,
      walletType: json['walletType'] as String? ?? 'none',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      rating: json['rating'] as int? ?? 0,
      referralCode: json['referralCode'] as String,
      referredBy: json['referredBy'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      subscription: json['subscription'] as String? ?? 'free',
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

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'walletAddress': walletAddress,
      'walletType': walletType,
      'balance': balance,
      'totalEarned': totalEarned,
      'rating': rating,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'role': role,
      'status': status,
      'subscription': subscription,
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

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      dateOfBirth: dateOfBirth,
      walletAddress: walletAddress,
      walletType: WalletType.values.firstWhere(
        (e) => e.name == walletType,
        orElse: () => WalletType.none,
      ),
      balance: balance,
      totalEarned: totalEarned,
      rating: rating,
      referralCode: referralCode,
      referredBy: referredBy,
      role: UserRole.values.firstWhere(
        (e) => e.name == role,
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => UserStatus.active,
      ),
      subscription: SubscriptionTier.values.firstWhere(
        (e) => e.name == subscription,
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionExpiresAt: subscriptionExpiresAt,
      dailyGenerationsUsed: dailyGenerationsUsed,
      lastGenerationDate: lastGenerationDate,
      interests: interests,
      preferences: preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      dateOfBirth: user.dateOfBirth,
      walletAddress: user.walletAddress,
      walletType: user.walletType.name,
      balance: user.balance,
      totalEarned: user.totalEarned,
      rating: user.rating,
      referralCode: user.referralCode,
      referredBy: user.referredBy,
      role: user.role.name,
      status: user.status.name,
      subscription: user.subscription.name,
      subscriptionExpiresAt: user.subscriptionExpiresAt,
      dailyGenerationsUsed: user.dailyGenerationsUsed,
      lastGenerationDate: user.lastGenerationDate,
      interests: user.interests,
      preferences: user.preferences,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// Copy with
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? walletAddress,
    String? walletType,
    double? balance,
    double? totalEarned,
    int? rating,
    String? referralCode,
    String? referredBy,
    String? role,
    String? status,
    String? subscription,
    DateTime? subscriptionExpiresAt,
    int? dailyGenerationsUsed,
    DateTime? lastGenerationDate,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
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
}

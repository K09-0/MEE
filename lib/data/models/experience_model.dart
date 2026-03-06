import '../../domain/entities/experience.dart';

/// Experience Model (Firestore)
/// 
/// Модель для работы с Firestore
class ExperienceModel {
  final String id;
  final String creatorId;
  final String type;
  final String title;
  final String? description;
  final String? aiPrompt;
  final String contentUrl;
  final String? thumbnailUrl;
  final String? previewUrl;
  final double price;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? publishedAt;
  final int salesCount;
  final int viewsCount;
  final int likesCount;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final bool isNft;
  final String? nftAddress;
  final List<String> purchasedBy;
  final double rating;
  final int reviewCount;
  final String contentRating;
  final String? language;
  final bool isFeatured;
  final DateTime? featuredAt;

  const ExperienceModel({
    required this.id,
    required this.creatorId,
    required this.type,
    required this.title,
    this.description,
    this.aiPrompt,
    required this.contentUrl,
    this.thumbnailUrl,
    this.previewUrl,
    required this.price,
    this.currency = 'usd',
    this.status = 'draft',
    required this.createdAt,
    required this.expiresAt,
    this.publishedAt,
    this.salesCount = 0,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.tags = const [],
    this.metadata = const {},
    this.isNft = false,
    this.nftAddress,
    this.purchasedBy = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.contentRating = 'everyone',
    this.language,
    this.isFeatured = false,
    this.featuredAt,
  });

  /// Create from Firestore document
  factory ExperienceModel.fromFirestore(Map<String, dynamic> json, String id) {
    return ExperienceModel(
      id: id,
      creatorId: json['creatorId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      aiPrompt: json['aiPrompt'] as String?,
      contentUrl: json['contentUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      previewUrl: json['previewUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'usd',
      status: json['status'] as String? ?? 'draft',
      createdAt: _parseTimestamp(json['createdAt']),
      expiresAt: _parseTimestamp(json['expiresAt']),
      publishedAt: json['publishedAt'] != null
          ? _parseTimestamp(json['publishedAt'])
          : null,
      salesCount: json['salesCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      likesCount: json['likesCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      isNft: json['isNft'] as bool? ?? false,
      nftAddress: json['nftAddress'] as String?,
      purchasedBy: (json['purchasedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      contentRating: json['contentRating'] as String? ?? 'everyone',
      language: json['language'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      featuredAt: json['featuredAt'] != null
          ? _parseTimestamp(json['featuredAt'])
          : null,
    );
  }

  /// Parse timestamp (handles both String and Timestamp)
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    // For Firestore Timestamp
    if (value is Map && value.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000,
      );
    }
    return DateTime.now();
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'type': type,
      'title': title,
      'description': description,
      'aiPrompt': aiPrompt,
      'contentUrl': contentUrl,
      'thumbnailUrl': thumbnailUrl,
      'previewUrl': previewUrl,
      'price': price,
      'currency': currency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'salesCount': salesCount,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'tags': tags,
      'metadata': metadata,
      'isNft': isNft,
      'nftAddress': nftAddress,
      'purchasedBy': purchasedBy,
      'rating': rating,
      'reviewCount': reviewCount,
      'contentRating': contentRating,
      'language': language,
      'isFeatured': isFeatured,
      'featuredAt': featuredAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  Experience toEntity() {
    return Experience(
      id: id,
      creatorId: creatorId,
      type: ExperienceType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ExperienceType.art,
      ),
      title: title,
      description: description,
      aiPrompt: aiPrompt,
      contentUrl: contentUrl,
      thumbnailUrl: thumbnailUrl,
      previewUrl: previewUrl,
      price: price,
      currency: Currency.values.firstWhere(
        (e) => e.name == currency,
        orElse: () => Currency.usd,
      ),
      status: ExperienceStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => ExperienceStatus.draft,
      ),
      createdAt: createdAt,
      expiresAt: expiresAt,
      publishedAt: publishedAt,
      salesCount: salesCount,
      viewsCount: viewsCount,
      likesCount: likesCount,
      tags: tags,
      metadata: metadata,
      isNft: isNft,
      nftAddress: nftAddress,
      purchasedBy: purchasedBy,
      rating: rating,
      reviewCount: reviewCount,
      contentRating: ContentRating.values.firstWhere(
        (e) => e.name == contentRating,
        orElse: () => ContentRating.everyone,
      ),
      language: language,
      isFeatured: isFeatured,
      featuredAt: featuredAt,
    );
  }

  /// Create from domain entity
  factory ExperienceModel.fromEntity(Experience experience) {
    return ExperienceModel(
      id: experience.id,
      creatorId: experience.creatorId,
      type: experience.type.name,
      title: experience.title,
      description: experience.description,
      aiPrompt: experience.aiPrompt,
      contentUrl: experience.contentUrl,
      thumbnailUrl: experience.thumbnailUrl,
      previewUrl: experience.previewUrl,
      price: experience.price,
      currency: experience.currency.name,
      status: experience.status.name,
      createdAt: experience.createdAt,
      expiresAt: experience.expiresAt,
      publishedAt: experience.publishedAt,
      salesCount: experience.salesCount,
      viewsCount: experience.viewsCount,
      likesCount: experience.likesCount,
      tags: experience.tags,
      metadata: experience.metadata,
      isNft: experience.isNft,
      nftAddress: experience.nftAddress,
      purchasedBy: experience.purchasedBy,
      rating: experience.rating,
      reviewCount: experience.reviewCount,
      contentRating: experience.contentRating.name,
      language: experience.language,
      isFeatured: experience.isFeatured,
      featuredAt: experience.featuredAt,
    );
  }

  /// Copy with
  ExperienceModel copyWith({
    String? id,
    String? creatorId,
    String? type,
    String? title,
    String? description,
    String? aiPrompt,
    String? contentUrl,
    String? thumbnailUrl,
    String? previewUrl,
    double? price,
    String? currency,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? publishedAt,
    int? salesCount,
    int? viewsCount,
    int? likesCount,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isNft,
    String? nftAddress,
    List<String>? purchasedBy,
    double? rating,
    int? reviewCount,
    String? contentRating,
    String? language,
    bool? isFeatured,
    DateTime? featuredAt,
  }) {
    return ExperienceModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      contentUrl: contentUrl ?? this.contentUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      publishedAt: publishedAt ?? this.publishedAt,
      salesCount: salesCount ?? this.salesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isNft: isNft ?? this.isNft,
      nftAddress: nftAddress ?? this.nftAddress,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      contentRating: contentRating ?? this.contentRating,
      language: language ?? this.language,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredAt: featuredAt ?? this.featuredAt,
    );
  }

  /// Check if active
  bool get isActive => status == 'active';

  /// Check if expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get time remaining
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Get popularity score
  double get popularityScore {
    final salesWeight = salesCount * 10.0;
    final viewsWeight = viewsCount * 0.1;
    final likesWeight = likesCount * 2.0;
    final ratingWeight = rating * reviewCount * 5.0;
    
    final hoursSincePublished = publishedAt != null
        ? DateTime.now().difference(publishedAt!).inHours
        : 24;
    final recencyBoost = hoursSincePublished < 24
        ? (24 - hoursSincePublished) * 5.0
        : 0.0;
    
    return salesWeight + viewsWeight + likesWeight + ratingWeight + recencyBoost;
  }
}

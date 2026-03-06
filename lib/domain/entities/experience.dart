import 'package:equatable/equatable.dart';

import 'user.dart';

/// Experience Entity
/// 
/// Представляет микроопыт (цифровой актив) в системе MEE
/// Это основная сущность приложения - создается с помощью AI и продается
class Experience extends Equatable {
  final String id;
  final String creatorId;
  final User? creator; // Populated when fetching
  final ExperienceType type;
  final String title;
  final String? description;
  final String? aiPrompt; // The prompt used for AI generation
  final String contentUrl; // URL to the generated content
  final String? thumbnailUrl;
  final String? previewUrl; // Preview for non-buyers
  final double price;
  final Currency currency;
  final ExperienceStatus status;
  final DateTime createdAt;
  final DateTime expiresAt; // FOMO timer
  final DateTime? publishedAt;
  final int salesCount;
  final int viewsCount;
  final int likesCount;
  final List<String> tags;
  final Map<String, dynamic> metadata; // Type-specific data
  final bool isNft;
  final String? nftAddress; // If minted as NFT
  final List<String> purchasedBy; // User IDs who purchased
  final double rating;
  final int reviewCount;
  final ContentRating contentRating;
  final String? language;
  final bool isFeatured;
  final DateTime? featuredAt;

  const Experience({
    required this.id,
    required this.creatorId,
    this.creator,
    required this.type,
    required this.title,
    this.description,
    this.aiPrompt,
    required this.contentUrl,
    this.thumbnailUrl,
    this.previewUrl,
    required this.price,
    this.currency = Currency.usd,
    this.status = ExperienceStatus.draft,
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
    this.contentRating = ContentRating.everyone,
    this.language,
    this.isFeatured = false,
    this.featuredAt,
  });

  /// Empty experience (for initial state)
  factory Experience.empty() => Experience(
    id: '',
    creatorId: '',
    type: ExperienceType.art,
    title: '',
    contentUrl: '',
    price: 0.0,
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(hours: 24)),
  );

  /// Check if experience is empty
  bool get isEmpty => id.isEmpty;

  /// Check if experience is active (available for purchase)
  bool get isActive => status == ExperienceStatus.active;

  /// Check if experience is sold out
  bool get isSoldOut => status == ExperienceStatus.soldOut;

  /// Check if experience has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if experience is still available
  bool get isAvailable => isActive && !isExpired && !isSoldOut;

  /// Get time remaining until expiration
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Get formatted time remaining string
  String get timeRemainingFormatted {
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
    } else {
      return '${remaining.inSeconds}s';
    }
  }

  /// Check if experience is expiring soon (< 1 hour)
  bool get isExpiringSoon => timeRemaining.inHours < 1 && !isExpired;

  /// Check if experience is trending (high engagement)
  bool get isTrending => viewsCount > 1000 && salesCount > 10;

  /// Get platform fee (20%)
  double get platformFee => price * 0.20;

  /// Get creator earnings (80%)
  double get creatorEarnings => price * 0.80;

  /// Get formatted price
  String get formattedPrice {
    switch (currency) {
      case Currency.usd:
        return '\$${price.toStringAsFixed(2)}';
      case Currency.eur:
        return '€${price.toStringAsFixed(2)}';
      case Currency.gbp:
        return '£${price.toStringAsFixed(2)}';
      case Currency.sol:
        return '${price.toStringAsFixed(4)} SOL';
      case Currency.ton:
        return '${price.toStringAsFixed(4)} TON';
    }
  }

  /// Check if user has purchased this experience
  bool isPurchasedBy(String userId) => purchasedBy.contains(userId);

  /// Get engagement rate (sales / views)
  double get engagementRate {
    if (viewsCount == 0) return 0.0;
    return (salesCount / viewsCount) * 100;
  }

  /// Get popularity score for ranking
  double get popularityScore {
    // Algorithm: weighted combination of sales, views, likes, and recency
    final salesWeight = salesCount * 10.0;
    final viewsWeight = viewsCount * 0.1;
    final likesWeight = likesCount * 2.0;
    final ratingWeight = rating * reviewCount * 5.0;
    
    // Recency boost (newer experiences get higher score)
    final hoursSincePublished = publishedAt != null
        ? DateTime.now().difference(publishedAt!).inHours
        : 24;
    final recencyBoost = hoursSincePublished < 24
        ? (24 - hoursSincePublished) * 5.0
        : 0.0;
    
    return salesWeight + viewsWeight + likesWeight + ratingWeight + recencyBoost;
  }

  /// Copy with method
  Experience copyWith({
    String? id,
    String? creatorId,
    User? creator,
    ExperienceType? type,
    String? title,
    String? description,
    String? aiPrompt,
    String? contentUrl,
    String? thumbnailUrl,
    String? previewUrl,
    double? price,
    Currency? currency,
    ExperienceStatus? status,
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
    ContentRating? contentRating,
    String? language,
    bool? isFeatured,
    DateTime? featuredAt,
  }) {
    return Experience(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'type': type.name,
      'title': title,
      'description': description,
      'aiPrompt': aiPrompt,
      'contentUrl': contentUrl,
      'thumbnailUrl': thumbnailUrl,
      'previewUrl': previewUrl,
      'price': price,
      'currency': currency.name,
      'status': status.name,
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
      'contentRating': contentRating.name,
      'language': language,
      'isFeatured': isFeatured,
      'featuredAt': featuredAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creator: json['creator'] != null
          ? User.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      type: ExperienceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExperienceType.art,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      aiPrompt: json['aiPrompt'] as String?,
      contentUrl: json['contentUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      previewUrl: json['previewUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: Currency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => Currency.usd,
      ),
      status: ExperienceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExperienceStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
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
      contentRating: ContentRating.values.firstWhere(
        (e) => e.name == json['contentRating'],
        orElse: () => ContentRating.everyone,
      ),
      language: json['language'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      featuredAt: json['featuredAt'] != null
          ? DateTime.parse(json['featuredAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    creatorId,
    creator,
    type,
    title,
    description,
    aiPrompt,
    contentUrl,
    thumbnailUrl,
    previewUrl,
    price,
    currency,
    status,
    createdAt,
    expiresAt,
    publishedAt,
    salesCount,
    viewsCount,
    likesCount,
    tags,
    metadata,
    isNft,
    nftAddress,
    purchasedBy,
    rating,
    reviewCount,
    contentRating,
    language,
    isFeatured,
    featuredAt,
  ];
}

/// Experience Type
enum ExperienceType {
  art,        // AI-generated images/art
  text,       // Stories, poems, scripts
  audio,      // Music, sound effects
  miniGame,   // Simple interactive games
  filter,     // AR filters (future)
  sticker,    // Sticker packs (future)
  template,   // Design templates (future)
}

/// Extension for ExperienceType
extension ExperienceTypeExtension on ExperienceType {
  String get displayName {
    switch (this) {
      case ExperienceType.art:
        return 'AI Art';
      case ExperienceType.text:
        return 'Story';
      case ExperienceType.audio:
        return 'Music';
      case ExperienceType.miniGame:
        return 'Mini Game';
      case ExperienceType.filter:
        return 'AR Filter';
      case ExperienceType.sticker:
        return 'Stickers';
      case ExperienceType.template:
        return 'Template';
    }
  }

  String get icon {
    switch (this) {
      case ExperienceType.art:
        return '🎨';
      case ExperienceType.text:
        return '📝';
      case ExperienceType.audio:
        return '🎵';
      case ExperienceType.miniGame:
        return '🎮';
      case ExperienceType.filter:
        return '✨';
      case ExperienceType.sticker:
        return '😊';
      case ExperienceType.template:
        return '📐';
    }
  }

  List<String> get suggestedPrompts {
    switch (this) {
      case ExperienceType.art:
        return [
          'Cyberpunk city at night with neon lights',
          'Abstract geometric patterns in purple and green',
          'Fantasy landscape with floating islands',
          'Portrait of a futuristic warrior',
        ];
      case ExperienceType.text:
        return [
          'Write a short sci-fi story about AI',
          'Create a mysterious detective plot',
          'Write a romantic poem about stars',
          'Generate a funny dialogue between robots',
        ];
      case ExperienceType.audio:
        return [
          'Upbeat electronic dance track',
          'Calm lo-fi beats for studying',
          'Epic orchestral battle music',
          'Retro synthwave nostalgia',
        ];
      case ExperienceType.miniGame:
        return [
          'Simple puzzle game with blocks',
          'Endless runner with obstacles',
          'Memory matching card game',
          'Quiz game with trivia questions',
        ];
      default:
        return [];
    }
  }
}

/// Experience Status
enum ExperienceStatus {
  draft,      // Being created
  pending,    // Under moderation review
  active,     // Available for purchase
  soldOut,    // All copies sold (if limited)
  expired,    // Time limit reached
  hidden,     // Hidden by creator
  removed,    // Removed by moderator
}

/// Currency
enum Currency {
  usd,
  eur,
  gbp,
  sol,  // Solana
  ton,  // TON
}

/// Content Rating
enum ContentRating {
  everyone,       // All ages
  teen,          // 10+
  mature,        // 17+
  adult,         // 18+
}

/// Extension for ContentRating
extension ContentRatingExtension on ContentRating {
  String get displayName {
    switch (this) {
      case ContentRating.everyone:
        return 'E - Everyone';
      case ContentRating.teen:
        return 'T - Teen (10+)';
      case ContentRating.mature:
        return 'M - Mature (17+)';
      case ContentRating.adult:
        return 'A - Adult (18+)';
    }
  }

  int get minimumAge {
    switch (this) {
      case ContentRating.everyone:
        return 0;
      case ContentRating.teen:
        return 10;
      case ContentRating.mature:
        return 17;
      case ContentRating.adult:
        return 18;
    }
  }
}

/// Experience Filter
class ExperienceFilter {
  final ExperienceType? type;
  final double? minPrice;
  final double? maxPrice;
  final ExperienceStatus? status;
  final String? creatorId;
  final List<String>? tags;
  final bool? isFeatured;
  final String? searchQuery;
  final ExperienceSortBy sortBy;
  final SortOrder sortOrder;

  const ExperienceFilter({
    this.type,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.creatorId,
    this.tags,
    this.isFeatured,
    this.searchQuery,
    this.sortBy = ExperienceSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
  });

  /// Empty filter
  factory ExperienceFilter.empty() => const ExperienceFilter();

  /// Copy with
  ExperienceFilter copyWith({
    ExperienceType? type,
    double? minPrice,
    double? maxPrice,
    ExperienceStatus? status,
    String? creatorId,
    List<String>? tags,
    bool? isFeatured,
    String? searchQuery,
    ExperienceSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return ExperienceFilter(
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Sort options
enum ExperienceSortBy {
  createdAt,
  price,
  popularity,
  salesCount,
  rating,
  expiresAt,
}

/// Sort order
enum SortOrder {
  ascending,
  descending,
}

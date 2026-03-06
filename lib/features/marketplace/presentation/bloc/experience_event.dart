part of 'experience_bloc.dart';

/// Experience Events
/// 
/// Все события, связанные с микроопытами
abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

/// Load experiences with filter
class LoadExperiencesRequested extends ExperienceEvent {
  final ExperienceFilter? filter;
  final int page;
  final int limit;

  const LoadExperiencesRequested({
    this.filter,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [filter, page, limit];
}

/// Load trending experiences
class LoadTrendingExperiencesRequested extends ExperienceEvent {
  final int limit;

  const LoadTrendingExperiencesRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Load new experiences
class LoadNewExperiencesRequested extends ExperienceEvent {
  final int limit;

  const LoadNewExperiencesRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Load expiring experiences
class LoadExpiringExperiencesRequested extends ExperienceEvent {
  final int limit;

  const LoadExpiringExperiencesRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Load experience detail
class LoadExperienceDetailRequested extends ExperienceEvent {
  final String experienceId;

  const LoadExperienceDetailRequested(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}

/// Create new experience
class CreateExperienceRequested extends ExperienceEvent {
  final ExperienceType type;
  final String title;
  final String? description;
  final String aiPrompt;
  final String contentUrl;
  final String? thumbnailUrl;
  final String? previewUrl;
  final double price;
  final Currency currency;
  final DateTime expiresAt;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final ContentRating contentRating;
  final String? language;

  const CreateExperienceRequested({
    required this.type,
    required this.title,
    this.description,
    required this.aiPrompt,
    required this.contentUrl,
    this.thumbnailUrl,
    this.previewUrl,
    required this.price,
    this.currency = Currency.usd,
    required this.expiresAt,
    this.tags = const [],
    this.metadata = const {},
    this.contentRating = ContentRating.everyone,
    this.language,
  });

  @override
  List<Object?> get props => [
    type,
    title,
    description,
    aiPrompt,
    contentUrl,
    thumbnailUrl,
    previewUrl,
    price,
    currency,
    expiresAt,
    tags,
    metadata,
    contentRating,
    language,
  ];
}

/// Purchase experience
class PurchaseExperienceRequested extends ExperienceEvent {
  final String experienceId;
  final PaymentMethod paymentMethod;

  const PurchaseExperienceRequested({
    required this.experienceId,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [experienceId, paymentMethod];
}

/// Toggle like on experience
class ToggleLikeExperienceRequested extends ExperienceEvent {
  final String experienceId;
  final String userId;

  const ToggleLikeExperienceRequested({
    required this.experienceId,
    required this.userId,
  });

  @override
  List<Object?> get props => [experienceId, userId];
}

/// Search experiences
class SearchExperiencesRequested extends ExperienceEvent {
  final String query;
  final int page;
  final int limit;

  const SearchExperiencesRequested({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

/// Load creator's experiences
class LoadCreatorExperiencesRequested extends ExperienceEvent {
  final String creatorId;
  final int page;
  final int limit;

  const LoadCreatorExperiencesRequested({
    required this.creatorId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [creatorId, page, limit];
}

/// Load purchased experiences
class LoadPurchasedExperiencesRequested extends ExperienceEvent {
  final String userId;
  final int page;
  final int limit;

  const LoadPurchasedExperiencesRequested({
    required this.userId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

/// Load liked experiences
class LoadLikedExperiencesRequested extends ExperienceEvent {
  final String userId;
  final int page;
  final int limit;

  const LoadLikedExperiencesRequested({
    required this.userId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

/// Report experience
class ReportExperienceRequested extends ExperienceEvent {
  final String experienceId;
  final String reason;
  final String? details;

  const ReportExperienceRequested({
    required this.experienceId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [experienceId, reason, details];
}

/// Publish experience (make active)
class PublishExperienceRequested extends ExperienceEvent {
  final String experienceId;

  const PublishExperienceRequested(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}

/// Delete experience
class DeleteExperienceRequested extends ExperienceEvent {
  final String experienceId;

  const DeleteExperienceRequested(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}

/// Update experience
class UpdateExperienceRequested extends ExperienceEvent {
  final String experienceId;
  final String? title;
  final String? description;
  final double? price;
  final DateTime? expiresAt;
  final List<String>? tags;

  const UpdateExperienceRequested({
    required this.experienceId,
    this.title,
    this.description,
    this.price,
    this.expiresAt,
    this.tags,
  });

  @override
  List<Object?> get props => [
    experienceId,
    title,
    description,
    price,
    expiresAt,
    tags,
  ];
}

/// Increment view count
class IncrementViewRequested extends ExperienceEvent {
  final String experienceId;

  const IncrementViewRequested(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}

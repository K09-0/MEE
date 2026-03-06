import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../entities/experience.dart';

/// Experience Repository Interface
/// 
/// Определяет контракт для операций с микроопытами
abstract class ExperienceRepository {
  /// Get experience by ID
  Future<Either<AppException, Experience>> getExperience(String id);

  /// Get experiences with filter and pagination
  Future<Either<AppException, List<Experience>>> getExperiences({
    ExperienceFilter? filter,
    int page = 1,
    int limit = 20,
  });

  /// Get trending experiences
  Future<Either<AppException, List<Experience>>> getTrendingExperiences({
    int limit = 20,
  });

  /// Get new experiences
  Future<Either<AppException, List<Experience>>> getNewExperiences({
    int limit = 20,
  });

  /// Get expiring soon experiences
  Future<Either<AppException, List<Experience>>> getExpiringSoon({
    int limit = 20,
  });

  /// Get experiences by creator
  Future<Either<AppException, List<Experience>>> getCreatorExperiences(
    String creatorId, {
    int page = 1,
    int limit = 20,
  });

  /// Get purchased experiences
  Future<Either<AppException, List<Experience>>> getPurchasedExperiences(
    String userId, {
    int page = 1,
    int limit = 20,
  });

  /// Get liked experiences
  Future<Either<AppException, List<Experience>>> getLikedExperiences(
    String userId, {
    int page = 1,
    int limit = 20,
  });

  /// Search experiences
  Future<Either<AppException, List<Experience>>> searchExperiences(
    String query, {
    int page = 1,
    int limit = 20,
  });

  /// Create new experience
  Future<Either<AppException, Experience>> createExperience({
    required ExperienceType type,
    required String title,
    String? description,
    required String aiPrompt,
    required String contentUrl,
    String? thumbnailUrl,
    String? previewUrl,
    required double price,
    Currency currency = Currency.usd,
    required DateTime expiresAt,
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
    ContentRating contentRating = ContentRating.everyone,
    String? language,
  });

  /// Update experience
  Future<Either<AppException, Experience>> updateExperience(
    String id, {
    String? title,
    String? description,
    double? price,
    DateTime? expiresAt,
    List<String>? tags,
    ExperienceStatus? status,
  });

  /// Delete experience
  Future<Either<AppException, void>> deleteExperience(String id);

  /// Publish experience (make active)
  Future<Either<AppException, Experience>> publishExperience(String id);

  /// Increment view count
  Future<Either<AppException, void>> incrementViews(String id);

  /// Like/unlike experience
  Future<Either<AppException, void>> toggleLike(String experienceId, String userId);

  /// Check if user liked experience
  Future<Either<AppException, bool>> isLiked(String experienceId, String userId);

  /// Purchase experience
  Future<Either<AppException, Experience>> purchaseExperience({
    required String experienceId,
    required PaymentMethod paymentMethod,
  });

  /// Check if user purchased experience
  Future<Either<AppException, bool>> isPurchased(
    String experienceId,
    String userId,
  );

  /// Get experience content (for buyers)
  Future<Either<AppException, String>> getExperienceContent(String experienceId);

  /// Report experience
  Future<Either<AppException, void>> reportExperience({
    required String experienceId,
    required String reason,
    String? details,
  });

  /// Stream of experience updates
  Stream<Experience?> experienceStream(String id);

  /// Stream of feed updates
  Stream<List<Experience>> feedStream({ExperienceFilter? filter});
}

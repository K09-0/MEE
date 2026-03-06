import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/experience.dart';
import '../../domain/repositories/experience_repository.dart';
import '../models/experience_model.dart';

/// Experience Repository Implementation
/// 
/// Реализация репозитория микроопытов с использованием Firestore
class ExperienceRepositoryImpl implements ExperienceRepository {
  final FirebaseFirestore _firestore;

  // Collection references
  CollectionReference get _experiencesCollection =>
      _firestore.collection('experiences');
  CollectionReference get _likesCollection =>
      _firestore.collection('likes');
  CollectionReference get _reportsCollection =>
      _firestore.collection('reports');

  ExperienceRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<AppException, Experience>> getExperience(String id) async {
    try {
      final doc = await _experiencesCollection.doc(id).get();

      if (!doc.exists) {
        return const Left(NotFoundException(message: 'Experience not found'));
      }

      final model = ExperienceModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Get experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getExperiences({
    ExperienceFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _experiencesCollection
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Apply filters
      if (filter?.type != null) {
        query = query.where('type', isEqualTo: filter!.type!.name);
      }

      if (filter?.minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: filter!.minPrice);
      }

      if (filter?.maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: filter!.maxPrice);
      }

      if (filter?.creatorId != null) {
        query = query.where('creatorId', isEqualTo: filter!.creatorId);
      }

      if (filter?.tags != null && filter!.tags!.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: filter.tags);
      }

      // Pagination
      if (page > 1) {
        final lastDoc = await query.limit((page - 1) * limit).get();
        if (lastDoc.docs.isNotEmpty) {
          query = query.startAfterDocument(lastDoc.docs.last);
        }
      }

      final snapshot = await query.get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get experiences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getTrendingExperiences({
    int limit = 20,
  }) async {
    try {
      // Get active experiences ordered by popularity
      final snapshot = await _experiencesCollection
          .where('status', isEqualTo: 'active')
          .orderBy('salesCount', descending: true)
          .orderBy('viewsCount', descending: true)
          .limit(limit)
          .get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get trending error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getNewExperiences({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _experiencesCollection
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get new experiences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getExpiringSoon({
    int limit = 20,
  }) async {
    try {
      final now = DateTime.now();
      final soon = now.add(const Duration(hours: 24));

      final snapshot = await _experiencesCollection
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: now)
          .where('expiresAt', isLessThan: soon)
          .orderBy('expiresAt', descending: false)
          .limit(limit)
          .get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get expiring soon error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getCreatorExperiences(
    String creatorId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _experiencesCollection
          .where('creatorId', isEqualTo: creatorId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get creator experiences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getPurchasedExperiences(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _experiencesCollection
          .where('purchasedBy', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get purchased experiences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> getLikedExperiences(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Get liked experience IDs
      final likesSnapshot = await _likesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final experienceIds = likesSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['experienceId'] as String)
          .toList();

      if (experienceIds.isEmpty) {
        return const Right([]);
      }

      // Get experiences
      final experiencesSnapshot = await _experiencesCollection
          .where(FieldPath.documentId, whereIn: experienceIds)
          .get();

      final experiences = experiencesSnapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Get liked experiences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<Experience>>> searchExperiences(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Simple search by title (in production, use Algolia or similar)
      final snapshot = await _experiencesCollection
          .where('status', isEqualTo: 'active')
          .orderBy('title')
          .startAt([query.toLowerCase()])
          .endAt(['${query.toLowerCase()}\uf8ff'])
          .limit(limit)
          .get();

      final experiences = snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();

      return Right(experiences);
    } catch (e, stackTrace) {
      AppLogger.e('Search experiences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      // Validate price
      if (price < 0.99 || price > 4.99) {
        return const Left(ValidationException(
          message: 'Price must be between \$0.99 and \$4.99',
        ));
      }

      // Create document
      final docRef = _experiencesCollection.doc();
      final model = ExperienceModel(
        id: docRef.id,
        creatorId: 'current_user_id', // Get from auth
        type: type.name,
        title: title,
        description: description,
        aiPrompt: aiPrompt,
        contentUrl: contentUrl,
        thumbnailUrl: thumbnailUrl,
        previewUrl: previewUrl,
        price: price,
        currency: currency.name,
        status: 'draft',
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        tags: tags,
        metadata: metadata,
        contentRating: contentRating.name,
        language: language,
      );

      await docRef.set(model.toFirestore());

      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Create experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, Experience>> updateExperience(
    String id, {
    String? title,
    String? description,
    double? price,
    DateTime? expiresAt,
    List<String>? tags,
    ExperienceStatus? status,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (expiresAt != null) updates['expiresAt'] = expiresAt.toIso8601String();
      if (tags != null) updates['tags'] = tags;
      if (status != null) updates['status'] = status.name;

      updates['updatedAt'] = DateTime.now().toIso8601String();

      await _experiencesCollection.doc(id).update(updates);

      // Get updated experience
      final doc = await _experiencesCollection.doc(id).get();
      final model = ExperienceModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Update experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> deleteExperience(String id) async {
    try {
      await _experiencesCollection.doc(id).delete();
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Delete experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, Experience>> publishExperience(String id) async {
    try {
      await _experiencesCollection.doc(id).update({
        'status': 'active',
        'publishedAt': DateTime.now().toIso8601String(),
      });

      final doc = await _experiencesCollection.doc(id).get();
      final model = ExperienceModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Publish experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> incrementViews(String id) async {
    try {
      await _experiencesCollection.doc(id).update({
        'viewsCount': FieldValue.increment(1),
      });
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Increment views error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> toggleLike(
    String experienceId,
    String userId,
  ) async {
    try {
      // Check if already liked
      final likeQuery = await _likesCollection
          .where('userId', isEqualTo: userId)
          .where('experienceId', isEqualTo: experienceId)
          .limit(1)
          .get();

      if (likeQuery.docs.isNotEmpty) {
        // Unlike
        await likeQuery.docs.first.reference.delete();
        await _experiencesCollection.doc(experienceId).update({
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        await _likesCollection.add({
          'userId': userId,
          'experienceId': experienceId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _experiencesCollection.doc(experienceId).update({
          'likesCount': FieldValue.increment(1),
        });
      }

      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Toggle like error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isLiked(
    String experienceId,
    String userId,
  ) async {
    try {
      final likeQuery = await _likesCollection
          .where('userId', isEqualTo: userId)
          .where('experienceId', isEqualTo: experienceId)
          .limit(1)
          .get();

      return Right(likeQuery.docs.isNotEmpty);
    } catch (e, stackTrace) {
      AppLogger.e('Check like error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, Experience>> purchaseExperience({
    required String experienceId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      // This should be handled by Cloud Function for security
      // For now, update locally
      await _experiencesCollection.doc(experienceId).update({
        'salesCount': FieldValue.increment(1),
        'purchasedBy': FieldValue.arrayUnion(['current_user_id']),
      });

      final doc = await _experiencesCollection.doc(experienceId).get();
      final model = ExperienceModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Purchase experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isPurchased(
    String experienceId,
    String userId,
  ) async {
    try {
      final doc = await _experiencesCollection.doc(experienceId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final purchasedBy = data?['purchasedBy'] as List<dynamic>? ?? [];

      return Right(purchasedBy.contains(userId));
    } catch (e, stackTrace) {
      AppLogger.e('Check purchased error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, String>> getExperienceContent(
    String experienceId,
  ) async {
    try {
      final doc = await _experiencesCollection.doc(experienceId).get();
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        return const Left(NotFoundException(message: 'Experience not found'));
      }

      return Right(data['contentUrl'] as String);
    } catch (e, stackTrace) {
      AppLogger.e('Get content error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> reportExperience({
    required String experienceId,
    required String reason,
    String? details,
  }) async {
    try {
      await _reportsCollection.add({
        'reporterId': 'current_user_id',
        'targetType': 'experience',
        'targetId': experienceId,
        'reason': reason,
        'details': details,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Report experience error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Stream<Experience?> experienceStream(String id) {
    return _experiencesCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final model = ExperienceModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      return model.toEntity();
    });
  }

  @override
  Stream<List<Experience>> feedStream({ExperienceFilter? filter}) {
    Query query = _experiencesCollection
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true);

    if (filter?.type != null) {
      query = query.where('type', isEqualTo: filter!.type!.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = ExperienceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return model.toEntity();
      }).toList();
    });
  }
}

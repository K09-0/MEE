import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:injectable/injectable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/experience.dart';
import '../../domain/enums/share_type.dart';
import '../../domain/repositories/viral_repository.dart';

@LazySingleton(as: ViralRepository)
class ViralRepositoryImpl implements ViralRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseDynamicLinks _dynamicLinks;

  ViralRepositoryImpl(
    this._firestore,
    this._auth,
    this._dynamicLinks,
  );

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _sharesCollection =>
      _firestore.collection('shares');

  CollectionReference<Map<String, dynamic>> get _referralsCollection =>
      _firestore.collection('referrals');

  @override
  Future<Either<AppException, String>> generateReferralCode() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      // Check if user already has a referral code
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      if (userDoc.exists) {
        final existingCode = userDoc.data()?['referralCode'] as String?;
        if (existingCode != null && existingCode.isNotEmpty) {
          return Right(existingCode);
        }
      }

      // Generate unique referral code
      String referralCode;
      bool isUnique = false;
      int attempts = 0;

      do {
        referralCode = _generateRandomCode();
        final existing = await _usersCollection
            .where('referralCode', isEqualTo: referralCode)
            .limit(1)
            .get();
        isUnique = existing.docs.isEmpty;
        attempts++;
      } while (!isUnique && attempts < 10);

      if (!isUnique) {
        // Fallback to user ID-based code
        referralCode = 'MEE${currentUser.uid.substring(0, 8).toUpperCase()}';
      }

      // Save referral code to user document
      await _usersCollection.doc(currentUser.uid).update({
        'referralCode': referralCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Right(referralCode);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to generate referral code: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error generating code: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, String>> getReferralCode() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      if (!userDoc.exists) {
        return Left(NotFoundException(message: 'User not found'));
      }

      final referralCode = userDoc.data()?['referralCode'] as String?;

      if (referralCode == null || referralCode.isEmpty) {
        // Generate new code if doesn't exist
        return generateReferralCode();
      }

      return Right(referralCode);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get referral code: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error getting code: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, void>> applyReferralCode(String code) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      // Normalize code
      final normalizedCode = code.trim().toUpperCase();

      // Prevent self-referral
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      final ownCode = userDoc.data()?['referralCode'] as String?;
      if (ownCode?.toUpperCase() == normalizedCode) {
        return Left(
          ValidationException(message: 'Cannot use your own referral code'),
        );
      }

      // Check if user already used a referral code
      final existingReferral = await _referralsCollection
          .where('referredUserId', isEqualTo: currentUser.uid)
          .where('status', whereIn: ['pending', 'completed'])
          .limit(1)
          .get();

      if (existingReferral.docs.isNotEmpty) {
        return Left(
          ValidationException(message: 'You have already used a referral code'),
        );
      }

      // Find referrer
      final referrerQuery = await _usersCollection
          .where('referralCode', isEqualTo: normalizedCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) {
        return Left(
          ValidationException(message: 'Invalid referral code'),
        );
      }

      final referrerId = referrerQuery.docs.first.id;

      // Create referral record
      await _referralsCollection.add({
        'referrerId': referrerId,
        'referredUserId': currentUser.uid,
        'referralCode': normalizedCode,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': null,
        'bonusAmount': 0.0,
      });

      // Update user's referrer
      await _usersCollection.doc(currentUser.uid).update({
        'referredBy': referrerId,
        'referralCodeUsed': normalizedCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Give welcome bonus to new user
      await _usersCollection.doc(currentUser.uid).update({
        'earnings': FieldValue.increment(1.0), // \$1 welcome bonus
        'welcomeBonusReceived': true,
      });

      // Create welcome bonus transaction
      await _firestore.collection('transactions').add({
        'userId': currentUser.uid,
        'amount': 1.0,
        'type': 'welcomeBonus',
        'status': 'completed',
        'paymentMethod': 'platformCredit',
        'metadata': {
          'referralCode': normalizedCode,
          'referrerId': referrerId,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to apply referral code: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error applying code: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getReferralStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      // Get total referrals
      final referralsQuery = await _referralsCollection
          .where('referrerId', isEqualTo: currentUser.uid)
          .get();

      final totalReferrals = referralsQuery.docs.length;
      final completedReferrals = referralsQuery.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      // Get total earnings from referrals
      final referralEarnings = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: 'referralBonus')
          .where('status', isEqualTo: 'completed')
          .get();

      final totalEarnings = referralEarnings.docs.fold<double>(
        0.0,
        (sum, doc) => sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0),
      );

      return Right({
        'totalReferrals': totalReferrals,
        'completedReferrals': completedReferrals,
        'pendingReferrals': totalReferrals - completedReferrals,
        'totalEarnings': totalEarnings,
        'referralCode': await getReferralCode().then(
          (result) => result.fold((l) => null, (r) => r),
        ),
      });
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get referral stats: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error getting stats: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, String>> createShareableLink({
    required String experienceId,
    String? customMessage,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final referralCode = currentUser != null
          ? await getReferralCode().then(
              (result) => result.fold((l) => null, (r) => r),
            )
          : null;

      final dynamicLinkParams = DynamicLinkParameters(
        uriPrefix: 'https://meeapp.page.link',
        link: Uri.parse(
          'https://mee.app/experience/$experienceId?ref=${referralCode ?? ''}',
        ),
        androidParameters: const AndroidParameters(
          packageName: 'com.mee.app',
          minimumVersion: 1,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.mee.app',
          minimumVersion: '1.0.0',
          appStoreId: '123456789',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: customMessage ?? 'Check out this amazing experience on MEE!',
          description: 'Discover unique AI-powered micro-experiences',
          imageUrl: Uri.parse(
            'https://mee.app/assets/share-preview.png',
          ),
        ),
      );

      final dynamicLink =
          await _dynamicLinks.buildShortLink(dynamicLinkParams);

      // Track share
      if (currentUser != null) {
        await _trackShare(
          userId: currentUser.uid,
          experienceId: experienceId,
          shareType: ShareType.link,
          shareUrl: dynamicLink.shortUrl.toString(),
        );
      }

      return Right(dynamicLink.shortUrl.toString());
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to create shareable link: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error creating link: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, void>> shareToSocial({
    required String experienceId,
    required ShareType platform,
    String? customMessage,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      // Create shareable link
      final linkResult = await createShareableLink(
        experienceId: experienceId,
        customMessage: customMessage,
      );

      final link = linkResult.fold(
        (failure) => 'https://mee.app/experience/$experienceId',
        (url) => url,
      );

      // Prepare share message
      final message = customMessage ??
          'Check out this amazing experience on MEE! 🚀\n\n$link';

      // Share using share_plus
      await Share.share(
        message,
        subject: 'Check out MEE!',
      );

      // Track share
      await _trackShare(
        userId: currentUser.uid,
        experienceId: experienceId,
        shareType: platform,
        shareUrl: link,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        UnknownException(message: 'Failed to share: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, void>> trackShareView(String shareId) async {
    try {
      await _sharesCollection.doc(shareId).update({
        'views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to track share view: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error tracking view: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, void>> trackShareClick(String shareId) async {
    try {
      await _sharesCollection.doc(shareId).update({
        'clicks': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to track share click: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error tracking click: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getShareStats(
    String experienceId,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthException(message: 'User not authenticated'));
      }

      final sharesQuery = await _sharesCollection
          .where('experienceId', isEqualTo: experienceId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      int totalShares = 0;
      int totalViews = 0;
      int totalClicks = 0;
      Map<String, int> sharesByPlatform = {};

      for (final doc in sharesQuery.docs) {
        final data = doc.data();
        totalShares++;
        totalViews += (data['views'] as num?)?.toInt() ?? 0;
        totalClicks += (data['clicks'] as num?)?.toInt() ?? 0;

        final platform = data['shareType'] as String?;
        if (platform != null) {
          sharesByPlatform[platform] = (sharesByPlatform[platform] ?? 0) + 1;
        }
      }

      return Right({
        'totalShares': totalShares,
        'totalViews': totalViews,
        'totalClicks': totalClicks,
        'ctr': totalViews > 0 ? (totalClicks / totalViews * 100) : 0.0,
        'sharesByPlatform': sharesByPlatform,
      });
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get share stats: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error getting stats: $e'),
      );
    }
  }

  @override
  Stream<Either<AppException, PendingDynamicLinkData>>
      onDynamicLinkReceived() async* {
    try {
      // Handle initial link (app opened from terminated state)
      final initialLink = await _dynamicLinks.getInitialLink();
      if (initialLink != null) {
        yield Right(initialLink);
      }

      // Handle links when app is in foreground/background
      await for (final linkData in _dynamicLinks.onLink) {
        yield Right(linkData);
      }
    } on FirebaseException catch (e) {
      yield Left(
        DatabaseException(
          message: 'Dynamic link error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      yield Left(
        UnknownException(message: 'Unexpected error with dynamic links: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> parseDeepLink(
    Uri deepLink,
  ) async {
    try {
      final pathSegments = deepLink.pathSegments;

      if (pathSegments.isEmpty) {
        return Left(ValidationException(message: 'Invalid deep link'));
      }

      final type = pathSegments[0];
      String? id;
      String? referralCode;

      if (pathSegments.length > 1) {
        id = pathSegments[1];
      }

      // Extract referral code from query parameters
      referralCode = deepLink.queryParameters['ref'];
      if (referralCode != null && referralCode.isEmpty) {
        referralCode = null;
      }

      return Right({
        'type': type,
        'id': id,
        'referralCode': referralCode,
        'fullUri': deepLink.toString(),
      });
    } catch (e) {
      return Left(
        ValidationException(message: 'Failed to parse deep link: $e'),
      );
    }
  }

  @override
  Future<Either<AppException, List<Map<String, dynamic>>>>
      getTrendingShares({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _sharesCollection
          .orderBy('clicks', descending: true)
          .limit(limit)
          .get();

      final trendingShares = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      return Right(trendingShares);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseException(
          message: 'Failed to get trending shares: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownException(message: 'Unexpected error: $e'),
      );
    }
  }

  // Helper Methods

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'MEE${List.generate(6, (_) => chars[random.nextInt(chars.length)]).join()}';
  }

  Future<void> _trackShare({
    required String userId,
    required String experienceId,
    required ShareType shareType,
    required String shareUrl,
  }) async {
    try {
      await _sharesCollection.add({
        'userId': userId,
        'experienceId': experienceId,
        'shareType': shareType.name,
        'shareUrl': shareUrl,
        'views': 0,
        'clicks': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's share count
      await _usersCollection.doc(userId).update({
        'totalShares': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to track share: $e');
    }
  }
}

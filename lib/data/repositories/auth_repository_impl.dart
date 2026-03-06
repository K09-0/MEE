import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Auth Repository Implementation
/// 
/// Реализация репозитория аутентификации с использованием Firebase Auth
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<Either<AppException, User>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      return _getUserFromFirestore(firebaseUser.uid);
    } catch (e, stackTrace) {
      AppLogger.e('Get current user error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      final result = await _getUserFromFirestore(firebaseUser.uid);
      return result.fold(
        (failure) => null,
        (user) => user,
      );
    });
  }

  @override
  Future<Either<AppException, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthException(message: 'Sign in failed'));
      }

      // Update last login
      await _usersCollection.doc(credential.user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      return _getUserFromFirestore(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.e('Sign in error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, User>> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      // Check if username is taken
      if (username != null && username.isNotEmpty) {
        final usernameQuery = await _usersCollection
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
        
        if (usernameQuery.docs.isNotEmpty) {
          return const Left(ValidationException(
            message: 'Username is already taken',
            errors: {'username': ['Username is already taken']},
          ));
        }
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthException(message: 'Sign up failed'));
      }

      // Create user document in Firestore
      final referralCode = _generateReferralCode();
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        username: username,
        referralCode: referralCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _usersCollection.doc(credential.user!.uid).set(userModel.toFirestore());

      // Send email verification
      await credential.user!.sendEmailVerification();

      return Right(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.e('Sign up error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, User>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return const Left(AuthException(message: 'Google sign in cancelled'));
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        return const Left(AuthException(message: 'Google sign in failed'));
      }

      // Check if user exists in Firestore
      final userDoc = await _usersCollection.doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create new user
        final referralCode = _generateReferralCode();
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          avatarUrl: userCredential.user!.photoURL,
          referralCode: referralCode,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _usersCollection.doc(userCredential.user!.uid).set(userModel.toFirestore());
        return Right(userModel.toEntity());
      }

      // Update last login
      await _usersCollection.doc(userCredential.user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      return _getUserFromFirestore(userCredential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.e('Google sign in error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, User>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      if (userCredential.user == null) {
        return const Left(AuthException(message: 'Apple sign in failed'));
      }

      // Check if user exists in Firestore
      final userDoc = await _usersCollection.doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create new user
        final referralCode = _generateReferralCode();
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: credential.email ?? userCredential.user!.email ?? '',
          displayName: credential.givenName != null
              ? '${credential.givenName} ${credential.familyName ?? ''}'
              : null,
          referralCode: referralCode,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _usersCollection.doc(userCredential.user!.uid).set(userModel.toFirestore());
        return Right(userModel.toEntity());
      }

      // Update last login
      await _usersCollection.doc(userCredential.user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      return _getUserFromFirestore(userCredential.user!.uid);
    } on SignInWithAppleAuthorizationException catch (e) {
      return Left(AuthException(message: 'Apple sign in failed: ${e.message}'));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.e('Apple sign in error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, User>> signInWithPhantom() async {
    // TODO: Implement Phantom wallet connection
    // This requires solana_mobile_client package integration
    return const Left(AuthException(
      message: 'Phantom wallet integration coming soon',
      code: 'NOT_IMPLEMENTED',
    ));
  }

  @override
  Future<Either<AppException, User>> signInWithTonConnect() async {
    // TODO: Implement TON Connect integration
    return const Left(AuthException(
      message: 'TON Connect integration coming soon',
      code: 'NOT_IMPLEMENTED',
    ));
  }

  @override
  Future<Either<AppException, User>> linkWallet({
    required String walletAddress,
    required WalletType walletType,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      await _usersCollection.doc(currentUser.uid).update({
        'walletAddress': walletAddress,
        'walletType': walletType.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return _getUserFromFirestore(currentUser.uid);
    } catch (e, stackTrace) {
      AppLogger.e('Link wallet error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> unlinkWallet(WalletType walletType) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      await _usersCollection.doc(currentUser.uid).update({
        'walletAddress': null,
        'walletType': 'none',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Unlink wallet error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.e('Password reset error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> verifyEmail(String code) async {
    // Email verification is handled by Firebase Auth
    // This method can be used for custom verification flows
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }
      
      await user.reload();
      
      if (user.emailVerified) {
        return const Right(null);
      } else {
        return const Left(AuthException(message: 'Email not verified'));
      }
    } catch (e, stackTrace) {
      AppLogger.e('Verify email error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }
      
      await user.sendEmailVerification();
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Resend verification error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, User>> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    DateTime? dateOfBirth,
    List<String>? interests,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      // Check username uniqueness if provided
      if (username != null && username.isNotEmpty) {
        final currentUserDoc = await _usersCollection.doc(currentUser.uid).get();
        final currentData = currentUserDoc.data() as Map<String, dynamic>?;
        final currentUsername = currentData?['username'] as String?;
        
        if (currentUsername != username) {
          final usernameQuery = await _usersCollection
              .where('username', isEqualTo: username)
              .limit(1)
              .get();
          
          if (usernameQuery.docs.isNotEmpty) {
            return const Left(ValidationException(
              message: 'Username is already taken',
              errors: {'username': ['Username is already taken']},
            ));
          }
        }
      }

      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (interests != null) updates['interests'] = interests;

      await _usersCollection.doc(currentUser.uid).update(updates);

      return _getUserFromFirestore(currentUser.uid);
    } catch (e, stackTrace) {
      AppLogger.e('Update profile error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, User>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      await _usersCollection.doc(currentUser.uid).update({
        'preferences': preferences,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return _getUserFromFirestore(currentUser.uid);
    } catch (e, stackTrace) {
      AppLogger.e('Update preferences error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('Sign out error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> deleteAccount() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      // Delete user data from Firestore
      await _usersCollection.doc(currentUser.uid).delete();
      
      // Delete Firebase Auth account
      await currentUser.delete();
      
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return const Left(AuthException(
          message: 'Please re-authenticate before deleting your account',
          code: 'REQUIRES_RECENT_LOGIN',
        ));
      }
      return Left(_handleFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.e('Delete account error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, String>> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      final token = await user.getIdToken(true);
      return Right(token);
    } catch (e, stackTrace) {
      AppLogger.e('Refresh token error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, String>> getIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthException(message: 'No user logged in'));
      }

      final token = await user.getIdToken();
      return Right(token);
    } catch (e, stackTrace) {
      AppLogger.e('Get ID token error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  // ==================== PRIVATE METHODS ====================

  /// Get user from Firestore
  Future<Either<AppException, User>> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      
      if (!doc.exists) {
        return const Left(NotFoundException(message: 'User not found'));
      }

      final userModel = UserModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      return Right(userModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Get user from Firestore error', error: e, stackTrace: stackTrace);
      return Left(UnknownException(message: e.toString()));
    }
  }

  /// Generate unique referral code
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final code = List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
    return 'MEE$code';
  }

  /// Handle Firebase Auth errors
  AppException _handleFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    AppLogger.w('Firebase Auth Error: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case 'invalid-email':
        return const ValidationException(
          message: 'Invalid email address',
          errors: {'email': ['Invalid email address']},
        );
      case 'user-disabled':
        return const AuthException(
          message: 'This account has been disabled',
          code: 'USER_DISABLED',
        );
      case 'user-not-found':
        return const AuthException(
          message: 'No account found with this email',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return const AuthException(
          message: 'Incorrect password',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return const ValidationException(
          message: 'Email is already registered',
          errors: {'email': ['Email is already registered']},
        );
      case 'weak-password':
        return const ValidationException(
          message: 'Password is too weak',
          errors: {'password': ['Password should be at least 8 characters']},
        );
      case 'invalid-credential':
        return const AuthException(
          message: 'Invalid credentials',
          code: 'INVALID_CREDENTIAL',
        );
      case 'account-exists-with-different-credential':
        return const AuthException(
          message: 'Account exists with different sign-in method',
          code: 'DIFFERENT_CREDENTIAL',
        );
      case 'operation-not-allowed':
        return const AuthException(
          message: 'This operation is not allowed',
          code: 'NOT_ALLOWED',
        );
      case 'too-many-requests':
        return const RateLimitException(
          message: 'Too many attempts. Please try again later.',
        );
      default:
        return AuthException(
          message: e.message ?? 'Authentication error',
          code: e.code,
        );
    }
  }
}

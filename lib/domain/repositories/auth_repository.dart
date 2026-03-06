import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../entities/user.dart';

/// Auth Repository Interface
/// 
/// Определяет контракт для операций аутентификации
/// Реализация находится в data слое
abstract class AuthRepository {
  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get current user
  Future<Either<AppException, User>> getCurrentUser();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with email and password
  Future<Either<AppException, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<AppException, User>> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  });

  /// Sign in with Google
  Future<Either<AppException, User>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<AppException, User>> signInWithApple();

  /// Sign in with crypto wallet (Phantom/Solana)
  Future<Either<AppException, User>> signInWithPhantom();

  /// Sign in with TON Connect
  Future<Either<AppException, User>> signInWithTonConnect();

  /// Link wallet to existing account
  Future<Either<AppException, User>> linkWallet({
    required String walletAddress,
    required WalletType walletType,
  });

  /// Unlink wallet
  Future<Either<AppException, void>> unlinkWallet(WalletType walletType);

  /// Send password reset email
  Future<Either<AppException, void>> sendPasswordResetEmail(String email);

  /// Verify email
  Future<Either<AppException, void>> verifyEmail(String code);

  /// Resend verification email
  Future<Either<AppException, void>> resendVerificationEmail();

  /// Update user profile
  Future<Either<AppException, User>> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    DateTime? dateOfBirth,
    List<String>? interests,
  });

  /// Update user preferences
  Future<Either<AppException, User>> updatePreferences(
    Map<String, dynamic> preferences,
  );

  /// Sign out
  Future<Either<AppException, void>> signOut();

  /// Delete account
  Future<Either<AppException, void>> deleteAccount();

  /// Refresh user token
  Future<Either<AppException, String>> refreshToken();

  /// Get ID token
  Future<Either<AppException, String>> getIdToken();
}

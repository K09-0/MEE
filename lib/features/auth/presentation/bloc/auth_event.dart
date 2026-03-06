part of 'auth_bloc.dart';

/// Auth Events
/// 
/// Все события, связанные с аутентификацией
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App started - check auth state
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Sign in with email requested
class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email requested
class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String? username;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.username,
  });

  @override
  List<Object?> get props => [email, password, username];
}

/// Sign in with Google requested
class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// Sign in with Apple requested
class SignInWithAppleRequested extends AuthEvent {
  const SignInWithAppleRequested();
}

/// Sign in with Phantom wallet requested
class SignInWithPhantomRequested extends AuthEvent {
  const SignInWithPhantomRequested();
}

/// Sign in with TON Connect requested
class SignInWithTonConnectRequested extends AuthEvent {
  const SignInWithTonConnectRequested();
}

/// Sign out requested
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Profile update requested
class ProfileUpdateRequested extends AuthEvent {
  final String? displayName;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final List<String>? interests;

  const ProfileUpdateRequested({
    this.displayName,
    this.username,
    this.bio,
    this.avatarUrl,
    this.dateOfBirth,
    this.interests,
  });

  @override
  List<Object?> get props => [
    displayName,
    username,
    bio,
    avatarUrl,
    dateOfBirth,
    interests,
  ];
}

/// Wallet link requested
class WalletLinkRequested extends AuthEvent {
  final String walletAddress;
  final WalletType walletType;

  const WalletLinkRequested({
    required this.walletAddress,
    required this.walletType,
  });

  @override
  List<Object?> get props => [walletAddress, walletType];
}

/// Wallet unlink requested
class WalletUnlinkRequested extends AuthEvent {
  final WalletType walletType;

  const WalletUnlinkRequested(this.walletType);

  @override
  List<Object?> get props => [walletType];
}

/// Password reset requested
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Referral code applied
class ReferralCodeApplied extends AuthEvent {
  final String code;

  const ReferralCodeApplied(this.code);

  @override
  List<Object?> get props => [code];
}

/// Email verification requested
class EmailVerificationRequested extends AuthEvent {
  const EmailVerificationRequested();
}

/// Resend verification email requested
class ResendVerificationEmailRequested extends AuthEvent {
  const ResendVerificationEmailRequested();
}

/// Delete account requested
class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth BLoC
/// 
/// Управляет состоянием аутентификации приложения
/// Обрабатывает вход, регистрацию, выход и обновление профиля
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignInWithAppleRequested>(_onSignInWithApple);
    on<SignInWithPhantomRequested>(_onSignInWithPhantom);
    on<SignInWithTonConnectRequested>(_onSignInWithTonConnect);
    on<SignOutRequested>(_onSignOut);
    on<ProfileUpdateRequested>(_onProfileUpdate);
    on<WalletLinkRequested>(_onWalletLink);
    on<WalletUnlinkRequested>(_onWalletUnlink);
    on<PasswordResetRequested>(_onPasswordReset);
    on<ReferralCodeApplied>(_onReferralCodeApplied);
  }

  /// Handle app start
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: App started, checking auth state');
    
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authRepository.getCurrentUser();
    
    result.fold(
      (failure) {
        AppLogger.i('AuthBloc: No authenticated user');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: User.empty(),
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: User authenticated: ${user.id}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      },
    );
  }

  /// Handle email sign in
  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign in with email requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Sign in failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Sign in successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle email sign up
  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign up with email requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.signUpWithEmail(
      email: event.email,
      password: event.password,
      username: event.username,
    );
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Sign up failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Sign up successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle Google sign in
  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign in with Google requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.signInWithGoogle();
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Google sign in failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Google sign in successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle Apple sign in
  Future<void> _onSignInWithApple(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign in with Apple requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.signInWithApple();
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Apple sign in failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Apple sign in successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle Phantom wallet sign in
  Future<void> _onSignInWithPhantom(
    SignInWithPhantomRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign in with Phantom requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.signInWithPhantom();
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Phantom sign in failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Phantom sign in successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle TON Connect sign in
  Future<void> _onSignInWithTonConnect(
    SignInWithTonConnectRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign in with TON Connect requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.signInWithTonConnect();
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: TON Connect sign in failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: TON Connect sign in successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle sign out
  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign out requested');
    
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authRepository.signOut();
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Sign out failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (_) {
        AppLogger.i('AuthBloc: Sign out successful');
        emit(const AuthState(
          status: AuthStatus.unauthenticated,
          user: User(
            id: '',
            email: '',
            referralCode: '',
            createdAt: null,
            updatedAt: null,
          ),
        ));
      },
    );
  }

  /// Handle profile update
  Future<void> _onProfileUpdate(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Profile update requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.updateProfile(
      displayName: event.displayName,
      username: event.username,
      bio: event.bio,
      avatarUrl: event.avatarUrl,
      dateOfBirth: event.dateOfBirth,
      interests: event.interests,
    );
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Profile update failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Profile update successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle wallet link
  Future<void> _onWalletLink(
    WalletLinkRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Wallet link requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.linkWallet(
      walletAddress: event.walletAddress,
      walletType: event.walletType,
    );
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Wallet link failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (user) {
        AppLogger.i('AuthBloc: Wallet link successful');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle wallet unlink
  Future<void> _onWalletUnlink(
    WalletUnlinkRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Wallet unlink requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.unlinkWallet(event.walletType);
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Wallet unlink failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (_) async {
        AppLogger.i('AuthBloc: Wallet unlink successful');
        // Refresh user data
        final userResult = await _authRepository.getCurrentUser();
        userResult.fold(
          (failure) {},
          (user) {
            emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              errorMessage: null,
            ));
          },
        );
      },
    );
  }

  /// Handle password reset
  Future<void> _onPasswordReset(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Password reset requested');
    
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await _authRepository.sendPasswordResetEmail(event.email);
    
    result.fold(
      (failure) {
        AppLogger.w('AuthBloc: Password reset failed - ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.userMessage,
        ));
      },
      (_) {
        AppLogger.i('AuthBloc: Password reset email sent');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle referral code application
  Future<void> _onReferralCodeApplied(
    ReferralCodeApplied event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Referral code applied: ${event.code}');
    
    // This would typically call a repository method
    // For now, just log it
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      errorMessage: null,
    ));
  }
}

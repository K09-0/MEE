part of 'auth_bloc.dart';

/// Auth Status
/// 
/// Возможные состояния аутентификации
enum AuthStatus {
  initial,        // Initial state
  loading,        // Loading/Processing
  authenticated,  // User is logged in
  unauthenticated, // User is not logged in
}

/// Auth State
/// 
/// Состояние аутентификации приложения
class AuthState extends Equatable {
  final AuthStatus status;
  final User user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user = const User(
      id: '',
      email: '',
      referralCode: '',
      createdAt: null,
      updatedAt: null,
    ),
    this.errorMessage,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Loading state
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  /// Authenticated state
  factory AuthState.authenticated(User user) => AuthState(
    status: AuthStatus.authenticated,
    user: user,
  );

  /// Unauthenticated state
  factory AuthState.unauthenticated() => const AuthState(
    status: AuthStatus.unauthenticated,
  );

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  /// Check if authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if has error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Copy with
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user.id}, error: $errorMessage)';
  }
}

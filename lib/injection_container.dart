import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/experience_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/viral_repository_impl.dart';
import 'domain/repositories/ai_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/experience_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/viral_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/creator/presentation/bloc/creator_bloc.dart';
import 'features/marketplace/presentation/bloc/experience_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'services/ai_service.dart';
import 'services/payment_service.dart';

/// Service Locator
///
/// Централизованное управление зависимостями
/// Использует GetIt для внедрения зависимостей
final sl = GetIt.instance;

/// Initialize dependency injection
///
/// Регистрирует все зависимости приложения
Future<void> init() async {
  AppLogger.section('Initializing Dependency Injection');

  // ==================== FEATURES - AUTH ====================

  // BLoC
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  // ==================== FEATURES - MARKETPLACE ====================

  // BLoC
  sl.registerFactory(
    () => ExperienceBloc(
      experienceRepository: sl(),
      transactionRepository: sl(),
    ),
  );

  // ==================== FEATURES - WALLET ====================

  // BLoC
  sl.registerFactory(
    () => WalletBloc(
      transactionRepository: sl(),
      authRepository: sl(),
    ),
  );

  // ==================== FEATURES - CREATOR ====================

  // BLoC
  sl.registerFactory(
    () => CreatorBloc(
      aiRepository: sl(),
      experienceRepository: sl(),
    ),
  );

  // ==================== REPOSITORIES ====================

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // Experience Repository
  sl.registerLazySingleton<ExperienceRepository>(
    () => ExperienceRepositoryImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // Transaction Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // AI Repository
  sl.registerLazySingleton<AIRepository>(
    () => AIService(httpClient: sl()),
  );

  // Viral Repository
  sl.registerLazySingleton<ViralRepository>(
    () => ViralRepositoryImpl(
      firestore: sl(),
      auth: sl(),
      dynamicLinks: sl(),
    ),
  );

  // ==================== SERVICES ====================

  // Payment Service
  sl.registerLazySingleton(
    () => PaymentService(
      firestore: sl(),
      functions: sl(),
    ),
  );

  // ==================== EXTERNAL ====================

  // Firebase
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  sl.registerLazySingleton(() => FirebaseDynamicLinks.instance);

  // Google Sign In
  sl.registerLazySingleton(() => GoogleSignIn());

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  AppLogger.i('Dependency Injection initialized successfully');
}

/// Reset dependencies (for testing)
void reset() {
  sl.reset();
}

/// Logger for DI
class AppLogger {
  static void section(String title) {
    print('═' * 60);
    print('  $title');
    print('═' * 60);
  }

  static void i(String message) {
    print('ℹ️ $message');
  }
}

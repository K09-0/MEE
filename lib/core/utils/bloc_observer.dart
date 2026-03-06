import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logger.dart';

/// BLoC Observer for logging state changes
/// 
/// Отслеживает все изменения состояния в приложении
/// Полезно для отладки и мониторинга
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      AppLogger.i('🆕 BLoC Created: ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      AppLogger.i('📤 Event: ${event.runtimeType} in ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      AppLogger.stateChange(
        bloc.runtimeType.toString(),
        change.currentState.runtimeType.toString(),
        change.nextState.runtimeType.toString(),
      );
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      AppLogger.i(
        '🔄 Transition: ${transition.currentState.runtimeType} → '
        '${transition.nextState.runtimeType} '
        '(Event: ${transition.event.runtimeType})',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.stateError(bloc.runtimeType.toString(), error.toString());
    AppLogger.e(
      'BLoC Error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      AppLogger.i('🗑️ BLoC Closed: ${bloc.runtimeType}');
    }
  }
}

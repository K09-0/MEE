import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:talker/talker.dart';

/// Application Logger
/// 
/// Централизованное логирование для отладки и мониторинга
/// Использует пакет logger для красивого вывода в dev режиме
/// и talker для расширенного логирования
class AppLogger {
  AppLogger._(); // Private constructor
  
  static late final Logger _logger;
  static late final Talker _talker;
  static bool _initialized = false;
  
  /// Initialize logger
  static void init() {
    if (_initialized) return;
    
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: kDebugMode ? Level.debug : Level.warning,
    );
    
    _talker = Talker(
      settings: TalkerSettings(
        enabled: kDebugMode,
        useHistory: true,
        maxHistoryItems: 100,
      ),
    );
    
    _initialized = true;
  }
  
  // ==================== STANDARD LOGGING ====================
  
  /// Debug log
  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) init();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Info log
  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) init();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// Warning log
  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) init();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// Error log
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) init();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// Verbose log
  static void v(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) init();
    _logger.t(message, error: error, stackTrace: stackTrace);
  }
  
  // ==================== TALKER LOGGING ====================
  
  /// Log with Talker (more detailed)
  static void talk(String message, {LogLevel level = LogLevel.info}) {
    if (!_initialized) init();
    _talker.log(message, level: level);
  }
  
  /// Log error with Talker
  static void talkError(String message, dynamic error, [StackTrace? stackTrace]) {
    if (!_initialized) init();
    _talker.error(message, error, stackTrace);
  }
  
  /// Log critical error
  static void critical(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) init();
    _talker.critical(message, error, stackTrace);
  }
  
  // ==================== SECTION LOGGING ====================
  
  /// Log section header
  static void section(String title) {
    if (!_initialized) init();
    _logger.i('═' * 60);
    _logger.i('  $title');
    _logger.i('═' * 60);
  }
  
  /// Log API request
  static void logRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    if (!_initialized) init();
    section('API REQUEST');
    _logger.i('Method: $method');
    _logger.i('URL: $url');
    if (headers != null) _logger.i('Headers: $headers');
    if (body != null) _logger.i('Body: $body');
  }
  
  /// Log API response
  static void logResponse(int statusCode, dynamic data, {int? durationMs}) {
    if (!_initialized) init();
    section('API RESPONSE');
    _logger.i('Status Code: $statusCode');
    if (durationMs != null) _logger.i('Duration: ${durationMs}ms');
    _logger.i('Data: $data');
  }
  
  /// Log API error
  static void logApiError(int statusCode, String message, {dynamic error}) {
    if (!_initialized) init();
    section('API ERROR');
    _logger.e('Status Code: $statusCode');
    _logger.e('Message: $message');
    if (error != null) _logger.e('Error: $error');
  }
  
  // ==================== PERFORMANCE LOGGING ====================
  
  /// Log performance metric
  static void performance(String operation, int durationMs) {
    if (!_initialized) init();
    final icon = durationMs < 100 ? '⚡' : durationMs < 500 ? '⏱️' : '🐌';
    _logger.i('$icon $operation took ${durationMs}ms');
  }
  
  /// Log memory usage
  static void memory(String tag) {
    if (!_initialized) init();
    final info = _talker.history;
    _logger.i('💾 [$tag] Memory info logged');
  }
  
  // ==================== NAVIGATION LOGGING ====================
  
  /// Log navigation event
  static void navigation(String from, String to, {dynamic arguments}) {
    if (!_initialized) init();
    _logger.i('🧭 Navigation: $from → $to');
    if (arguments != null) _logger.i('Arguments: $arguments');
  }
  
  /// Log route information
  static void route(String routeName, {Map<String, dynamic>? params}) {
    if (!_initialized) init();
    _logger.i('📍 Route: $routeName');
    if (params != null && params.isNotEmpty) {
      _logger.i('Parameters: $params');
    }
  }
  
  // ==================== USER ACTION LOGGING ====================
  
  /// Log user action (for analytics)
  static void userAction(String action, {Map<String, dynamic>? properties}) {
    if (!_initialized) init();
    _logger.i('👤 User Action: $action');
    if (properties != null) {
      _logger.i('Properties: $properties');
    }
  }
  
  /// Log button tap
  static void buttonTap(String buttonName, {String? screen}) {
    if (!_initialized) init();
    final location = screen != null ? ' on $screen' : '';
    _logger.i('👆 Button tapped: $buttonName$location');
  }
  
  // ==================== STATE LOGGING ====================
  
  /// Log state change
  static void stateChange(String blocName, String from, String to) {
    if (!_initialized) init();
    _logger.i('🔄 $blocName: $from → $to');
  }
  
  /// Log state error
  static void stateError(String blocName, String error) {
    if (!_initialized) init();
    _logger.e('❌ $blocName Error: $error');
  }
  
  // ==================== DATABASE LOGGING ====================
  
  /// Log Firestore operation
  static void firestore(String operation, String collection, {String? docId, dynamic data}) {
    if (!_initialized) init();
    _logger.i('🔥 Firestore $operation: $collection${docId != null ? '/$docId' : ''}');
    if (data != null) _logger.i('Data: $data');
  }
  
  /// Log cache operation
  static void cache(String operation, String key, {dynamic value}) {
    if (!_initialized) init();
    _logger.i('💾 Cache $operation: $key');
    if (value != null) _logger.i('Value: $value');
  }
  
  // ==================== SECURITY LOGGING ====================
  
  /// Log security event
  static void security(String event, {String? userId, String? details}) {
    if (!_initialized) init();
    _logger.w('🔒 Security: $event');
    if (userId != null) _logger.w('User: $userId');
    if (details != null) _logger.w('Details: $details');
  }
  
  /// Log authentication event
  static void auth(String event, {String? userId, String? method}) {
    if (!_initialized) init();
    _logger.i('🔐 Auth: $event');
    if (userId != null) _logger.i('User: $userId');
    if (method != null) _logger.i('Method: $method');
  }
  
  // ==================== GETTERS ====================
  
  /// Get talker instance for advanced usage
  static Talker get talker => _talker;
  
  /// Get logger history
  static List<TalkerData> get history => _talker.history;
  
  /// Clear logger history
  static void clearHistory() => _talker.clearHistory();
}

/// Log levels for Talker
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Extension for easy logging
extension LogExtension on Object {
  /// Log as debug
  void logD([String? prefix]) {
    AppLogger.d('${prefix != null ? '[$prefix] ' : ''}$this');
  }
  
  /// Log as info
  void logI([String? prefix]) {
    AppLogger.i('${prefix != null ? '[$prefix] ' : ''}$this');
  }
  
  /// Log as error
  void logE([String? prefix, dynamic error, StackTrace? stackTrace]) {
    AppLogger.e(
      '${prefix != null ? '[$prefix] ' : ''}$this',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Base Exception class for MEE App
/// 
/// Все кастомные исключения должны наследоваться от этого класса
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Server Exception
/// 
/// Исключение при ошибке сервера (5xx)
class ServerException extends AppException {
  const ServerException({
    String message = 'Server error occurred',
    String? code = 'SERVER_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Network Exception
/// 
/// Исключение при отсутствии интернет-соединения
class NetworkException extends AppException {
  const NetworkException({
    String message = 'No internet connection',
    String? code = 'NETWORK_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Timeout Exception
/// 
/// Исключение при превышении времени ожидания
class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Request timed out',
    String? code = 'TIMEOUT_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Cache Exception
/// 
/// Исключение при ошибке кэширования
class CacheException extends AppException {
  const CacheException({
    String message = 'Cache error occurred',
    String? code = 'CACHE_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Authentication Exception
/// 
/// Исключение при ошибке аутентификации
class AuthException extends AppException {
  const AuthException({
    String message = 'Authentication failed',
    String? code = 'AUTH_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Unauthorized Exception
/// 
/// Исключение при отсутствии прав доступа (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized access',
    String? code = 'UNAUTHORIZED',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Not Found Exception
/// 
/// Исключение при отсутствии ресурса (404)
class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Resource not found',
    String? code = 'NOT_FOUND',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Validation Exception
/// 
/// Исключение при ошибке валидации (400)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Validation failed',
    String? code = 'VALIDATION_ERROR',
    this.errors,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  /// Get first error message
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    return errors!.values.first.firstOrNull;
  }

  /// Get all error messages as list
  List<String> get allErrors {
    if (errors == null) return [];
    return errors!.values.expand((e) => e).toList();
  }
}

/// Payment Exception
/// 
/// Исключение при ошибке платежа
class PaymentException extends AppException {
  const PaymentException({
    String message = 'Payment failed',
    String? code = 'PAYMENT_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// AI Generation Exception
/// 
/// Исключение при ошибке генерации AI
class AIGenerationException extends AppException {
  const AIGenerationException({
    String message = 'AI generation failed',
    String? code = 'AI_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Rate Limit Exception
/// 
/// Исключение при превышении лимита запросов (429)
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    String message = 'Rate limit exceeded',
    String? code = 'RATE_LIMIT',
    this.retryAfter,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Content Moderation Exception
/// 
/// Исключение при обнаружении запрещенного контента
class ContentModerationException extends AppException {
  const ContentModerationException({
    String message = 'Content flagged for moderation',
    String? code = 'CONTENT_FLAGGED',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Daily Limit Exception
/// 
/// Исключение при превышении дневного лимита
class DailyLimitException extends AppException {
  final int? limit;
  final DateTime? resetTime;

  const DailyLimitException({
    String message = 'Daily limit reached',
    String? code = 'DAILY_LIMIT',
    this.limit,
    this.resetTime,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Insufficient Funds Exception
/// 
/// Исключение при недостатке средств
class InsufficientFundsException extends AppException {
  final double? required;
  final double? available;

  const InsufficientFundsException({
    String message = 'Insufficient funds',
    String? code = 'INSUFFICIENT_FUNDS',
    this.required,
    this.available,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Experience Expired Exception
/// 
/// Исключение при попытке купить истекший опыт
class ExperienceExpiredException extends AppException {
  final DateTime? expiredAt;

  const ExperienceExpiredException({
    String message = 'Experience has expired',
    String? code = 'EXPERIENCE_EXPIRED',
    this.expiredAt,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Already Purchased Exception
/// 
/// Исключение при попытке купить уже купленный опыт
class AlreadyPurchasedException extends AppException {
  const AlreadyPurchasedException({
    String message = 'Experience already purchased',
    String? code = 'ALREADY_PURCHASED',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Crypto Wallet Exception
/// 
/// Исключение при ошибке криптокошелька
class CryptoWalletException extends AppException {
  const CryptoWalletException({
    String message = 'Wallet operation failed',
    String? code = 'WALLET_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Deep Link Exception
/// 
/// Исключение при обработке deep link
class DeepLinkException extends AppException {
  const DeepLinkException({
    String message = 'Failed to process link',
    String? code = 'DEEP_LINK_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Unknown Exception
/// 
/// Неизвестное исключение
class UnknownException extends AppException {
  const UnknownException({
    String message = 'An unknown error occurred',
    String? code = 'UNKNOWN_ERROR',
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Extension to convert exceptions to user-friendly messages
extension AppExceptionExtension on AppException {
  /// Get user-friendly error message
  String get userMessage {
    switch (runtimeType) {
      case NetworkException:
        return 'No internet connection. Please check your network.';
      case TimeoutException:
        return 'Request timed out. Please try again.';
      case ServerException:
        return 'Server error. Please try again later.';
      case UnauthorizedException:
        return 'Session expired. Please log in again.';
      case NotFoundException:
        return 'Resource not found.';
      case ValidationException:
        return (this as ValidationException).firstError ?? 'Please check your input.';
      case PaymentException:
        return 'Payment failed. Please try again.';
      case AIGenerationException:
        return 'AI generation failed. Please try again.';
      case RateLimitException:
        return 'Too many requests. Please wait a moment.';
      case ContentModerationException:
        return 'Content flagged for review. Please try different content.';
      case DailyLimitException:
        return 'Daily limit reached. Upgrade to Pro or try tomorrow.';
      case InsufficientFundsException:
        return 'Insufficient funds. Please add more.';
      case ExperienceExpiredException:
        return 'This experience has expired.';
      case AlreadyPurchasedException:
        return 'You already own this experience.';
      case CryptoWalletException:
        return 'Wallet operation failed. Please try again.';
      case DeepLinkException:
        return 'Invalid link. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Check if error is retryable
  bool get isRetryable {
    return this is NetworkException ||
           this is TimeoutException ||
           this is ServerException ||
           this is RateLimitException;
  }
}

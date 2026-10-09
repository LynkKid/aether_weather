import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

abstract class IAppLogger {
  void debug(String message, [dynamic error, StackTrace? stackTrace]);
  void info(String message, [dynamic error, StackTrace? stackTrace]);
  void warning(String message, [dynamic error, StackTrace? stackTrace]);
  void error(String message, [dynamic error, StackTrace? stackTrace]);
}

class AppLogger implements IAppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static final RegExp _emailRegex =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _phoneRegex = RegExp(r'\b(?:\+?\d{1,3}[-.\s]?)?\d{9,11}\b');

  static String maskPII(String text) {
    var masked = text.replaceAllMapped(_emailRegex, (match) {
      final email = match.group(0)!;
      final parts = email.split('@');
      if (parts[0].length <= 2) return '***@${parts[1]}';
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    });

    masked = masked.replaceAllMapped(_phoneRegex, (match) {
      final phone = match.group(0)!;
      if (phone.length <= 4) return '****';
      return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
    });

    return masked;
  }

  void _log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final maskedMessage = maskPII(message);
    final prefix = switch (level) {
      LogLevel.debug => '🔍 [DEBUG]',
      LogLevel.info => 'ℹ️ [INFO]',
      LogLevel.warning => '⚠️ [WARN]',
      LogLevel.error => '❌ [ERROR]',
    };

    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    debugPrint('$prefix [$timestamp] $maskedMessage');

    if (error != null) {
      debugPrint('   ↳ Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('   ↳ StackTrace: $stackTrace');
    }
  }

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.debug, message, error, stackTrace);

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.info, message, error, stackTrace);

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.warning, message, error, stackTrace);

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);
}

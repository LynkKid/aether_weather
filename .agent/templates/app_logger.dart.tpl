// Template: lib/core/logging/app_logger.dart - TRUNG LẬP STACK
// Wrapper logging tập trung (rules/09). Cấm dùng print()/debugPrint().
// GHI CHÚ: ví dụ dưới dùng package `logger`; nếu PROJECT_STACK.md chọn lib khác
// (talker, logging, ...) hãy giữ nguyên interface (d/i/w/e + mask) và thay phần impl bên trong.
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

abstract final class AppLogger {
  static final Logger _logger = Logger(
    filter: _ReleaseAwareFilter(),
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 100),
  );

  static const Set<String> _sensitiveKeys = {
    'password', 'token', 'accessToken', 'refreshToken',
    'identityNumber', 'creditCard', 'phone', 'pinCode', 'otp',
  };

  static void d(dynamic message) => _logger.d(_mask(message));
  static void i(dynamic message) => _logger.i(_mask(message));
  static void w(dynamic message) => _logger.w(_mask(message));
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(_mask(message), error: error, stackTrace: stackTrace);

  /// Che giấu trường nhạy cảm trong Map trước khi log (rules/08, rules/09).
  static Object? _mask(dynamic message) {
    if (message is Map) {
      return message.map(
        (key, value) => MapEntry(
          key,
          _sensitiveKeys.contains(key.toString()) ? '******' : value,
        ),
      );
    }
    return message;
  }
}

/// Ở release chỉ log từ warning trở lên.
class _ReleaseAwareFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) return event.level.index >= Level.warning.index;
    return true;
  }
}

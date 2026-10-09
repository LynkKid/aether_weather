// Template: lib/core/error/app_failure.dart - TRUNG LẬP STACK
// Phân cấp lỗi nghiệp vụ (rules/06). PURE DART - không import Flutter/Network/DB.
// GHI CHÚ: dùng khi PROJECT_STACK.md chọn kiểu lỗi Result/Either (fpdart/dartz hoặc Result sealed class).
//          UseCase/Repository trả về Either<AppFailure, T> hoặc Result<T> và tiêu thụ bằng fold/switch.
//          Nếu dự án chọn xử lý bằng exception thuần thì có thể bỏ file này.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

/// Lỗi HTTP 4xx/5xx hoặc mất mạng.
class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;
}

/// Lỗi đọc/ghi lưu trữ cục bộ (local DB/cache).
class CacheFailure extends AppFailure {
  const CacheFailure(super.message);
}

/// Lỗi validate dữ liệu nhập của người dùng.
class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

/// Lỗi ngoài dự kiến / không phân loại được.
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message);
}

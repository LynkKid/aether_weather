sealed class AppFailure {
  final String message;
  final String? code;
  final dynamic cause;

  const AppFailure(this.message, {this.code, this.cause});

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

final class NetworkFailure extends AppFailure {
  final int? statusCode;
  const NetworkFailure(super.message, {super.code, super.cause, this.statusCode});
}

final class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(super.message, {super.code, super.cause, this.statusCode});
}

final class LocationFailure extends AppFailure {
  const LocationFailure(super.message, {super.code, super.cause});
}

final class CacheFailure extends AppFailure {
  const CacheFailure(super.message, {super.code, super.cause});
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message, {super.code, super.cause});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {super.code, super.cause});
}

import 'package:kid_matix/core/error/app_error_code.dart';

/// Base type of every expected failure raised by the data layer.
sealed class AppException implements Exception {
  /// Creates an exception identified by [code].
  const AppException({required this.code, this.message});

  /// Stable identifier resolved to localized text by the presentation layer.
  final AppErrorCode code;

  /// Technical detail meant for logs; never shown to the user.
  final String? message;

  @override
  String toString() => '$runtimeType(${code.name}, $message)';
}

/// Local storage could not be read or written.
final class CacheException extends AppException {
  /// Creates a storage failure.
  const CacheException({super.message}) : super(code: AppErrorCode.cache);
}

/// A submitted value breaks a business rule.
final class ValidationException extends AppException {
  /// Creates a validation failure.
  const ValidationException({super.message})
    : super(code: AppErrorCode.validation);
}

/// The requested item does not exist.
final class NotFoundException extends AppException {
  /// Creates a missing-item failure.
  const NotFoundException({super.message}) : super(code: AppErrorCode.notFound);
}

/// The operation clashes with existing data.
final class ConflictException extends AppException {
  /// Creates a conflict failure.
  const ConflictException({super.message}) : super(code: AppErrorCode.conflict);
}

/// A business limit is reached, such as the number of profiles.
final class LimitReachedException extends AppException {
  /// Creates a limit failure.
  const LimitReachedException({super.message})
    : super(code: AppErrorCode.limitReached);
}

/// A file is damaged or is not what the app expects.
final class InvalidFileException extends AppException {
  /// Creates a damaged-file failure.
  const InvalidFileException({super.message})
    : super(code: AppErrorCode.invalidFile);
}

/// A file was written by a newer version of the app.
final class UnsupportedVersionException extends AppException {
  /// Creates a file-version failure.
  const UnsupportedVersionException({super.message})
    : super(code: AppErrorCode.unsupportedVersion);
}

/// The person refused a permission the app asked for.
final class PermissionDeniedException extends AppException {
  /// Creates a refused-permission failure.
  const PermissionDeniedException({super.message})
    : super(code: AppErrorCode.permissionDenied);
}

/// Any failure that has no dedicated type.
final class UnknownException extends AppException {
  /// Creates an unclassified failure.
  const UnknownException({super.message}) : super(code: AppErrorCode.unknown);
}

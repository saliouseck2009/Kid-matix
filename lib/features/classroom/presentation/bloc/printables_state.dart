import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// The page of the printable sheets: the unit chosen and the last print.
@immutable
final class PrintablesState {
  /// Creates the state.
  const PrintablesState({
    required this.domainId,
    required this.unitKey,
    this.isBusy = false,
    this.isShared = false,
    this.errorCode,
  });

  /// Domain of the exercises.
  final String domainId;

  /// Unit of the exercises.
  final String unitKey;

  /// Whether a sheet is being made.
  final bool isBusy;

  /// Whether the last sheet went to the share sheet.
  final bool isShared;

  /// Why the last sheet failed, or `null`.
  final AppErrorCode? errorCode;
}

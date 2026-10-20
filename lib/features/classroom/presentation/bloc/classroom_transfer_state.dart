import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:meta/meta.dart';

/// Where a class file being sent or received stands.
@immutable
sealed class ClassroomTransferState {
  const ClassroomTransferState();
}

/// Nothing is going on.
final class ClassroomTransferIdle extends ClassroomTransferState {
  /// Creates the state; [lastExportAt] when the class was already sent.
  const ClassroomTransferIdle({this.lastExportAt});

  /// When the last file of the class left this tablet, or `null`.
  final DateTime? lastExportAt;
}

/// A file is being written, shared, read or merged.
final class ClassroomTransferBusy extends ClassroomTransferState {
  /// Creates the state.
  const ClassroomTransferBusy();
}

/// The file of the class went to the share sheet.
final class ClassroomTransferShared extends ClassroomTransferState {
  /// Creates the state.
  const ClassroomTransferShared();
}

/// A received file was merged.
final class ClassroomTransferMerged extends ClassroomTransferState {
  /// Creates the state.
  const ClassroomTransferMerged({required this.report});

  /// What it added.
  final ClassroomMergeReport report;
}

/// The file could not be sent or received.
final class ClassroomTransferFailed extends ClassroomTransferState {
  /// Creates the state.
  const ClassroomTransferFailed({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}

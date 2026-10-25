import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';

/// The texts of the QR codes of results.
extension ResultsQrMessages on BuildContext {
  /// Why a code could not be made or merged.
  String qrFailureOf(AppErrorCode code) {
    return switch (code) {
      AppErrorCode.validation => l10n.classroomQrNothing,
      AppErrorCode.limitReached => l10n.classroomQrTooBig,
      AppErrorCode.invalidFile => l10n.classroomQrInvalid,
      AppErrorCode.unsupportedVersion => l10n.classroomQrVersion,
      AppErrorCode.notFound => l10n.classroomQrUnknown,
      _ => l10n.classroomErrorGeneric,
    };
  }

  /// What a merged code added.
  String qrMergedOf(ClassroomMergeReport report) {
    return l10n.classroomImportDone(
      report.classroomName,
      report.addedPupilCount,
      report.addedSessionCount,
    );
  }
}

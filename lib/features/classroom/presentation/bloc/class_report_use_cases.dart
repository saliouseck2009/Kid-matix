import 'package:kid_matix/features/classroom/domain/usecases/get_class_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_program_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/share_files_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the reports of the teacher area.
@immutable
final class ClassReportUseCases {
  /// Groups the use cases.
  const ClassReportUseCases({
    required this.getClassReport,
    required this.getProgramReport,
    required this.share,
  });

  /// Computes the report of a class.
  final GetClassReportUseCase getClassReport;

  /// Reads the periods of every class and consolidates their reports.
  final GetProgramReportUseCase getProgramReport;

  /// Sends files to the share sheet.
  final ShareFilesUseCase share;
}

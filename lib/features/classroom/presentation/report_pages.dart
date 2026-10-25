import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/program_report.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/program_periods_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/report_export_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/program_report_page.dart';
import 'package:kid_matix/features/classroom/presentation/printable_pages.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';
import 'package:kid_matix/features/classroom/presentation/report/program_report_files.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/report_export_card.dart';

/// Builds the reports of the teacher area (F31-02 to F31-04): the report
/// of a class, named and anonymous, the report of a school or a program,
/// anonymous only, and the printable sheets (F31-07).
final class ReportPages {
  /// Creates the factory.
  const ReportPages({required this._useCases, this.printables});

  final ClassReportUseCases _useCases;

  /// The printable sheets (F31-07), or `null`.
  final PrintablePages? printables;

  /// « Rapport de la classe » over the [periods] of [classroomId].
  Widget buildClassReportCard({
    required String classroomId,
    required List<AssessmentPeriod> periods,
  }) {
    if (periods.isEmpty) {
      return Builder(
        builder: (BuildContext context) => ReportPlaceholderCard(
          title: context.l10n.classroomReportCardTitle,
          message: context.l10n.classroomReportNeedsAssessment,
        ),
      );
    }
    return BlocProvider<ReportExportCubit<ClassProgressReport>>(
      key: ValueKey<String>('class-${_keyOf(periods)}'),
      create: (_) => ReportExportCubit<ClassProgressReport>(
        periods: periods,
        source: ({String? fromKey, required String toKey}) =>
            _useCases.getClassReport(
              params: (
                classroomId: classroomId,
                fromKey: fromKey,
                toKey: toKey,
              ),
            ),
        share: _useCases.share,
      ),
      child: Builder(
        builder: (BuildContext context) =>
            ReportExportCard<ClassProgressReport>(
              title: context.l10n.classroomReportCardTitle,
              hint: context.l10n.classroomReportCardHint,
              periods: periods,
              rendererOf: (BuildContext context, ReportFileKind kind) {
                final ClassReportFiles files = ClassReportFiles(
                  l10n: context.l10n,
                );
                return (ClassProgressReport report) =>
                    files.filesOf(report, kind);
              },
            ),
      ),
    );
  }

  /// « Rapport d'école ou de programme » under « Mes classes ».
  Widget buildProgramReportButton({required VoidCallback onOpen}) {
    return Builder(
      builder: (BuildContext context) => DepthButton(
        label: context.l10n.classroomProgramOpen,
        icon: Icons.summarize_rounded,
        variant: DepthButtonVariant.secondary,
        onPressed: onOpen,
      ),
    );
  }

  /// The page of the school or program report.
  Widget buildProgramReportPage({required VoidCallback onBack}) {
    return BlocProvider<ProgramPeriodsCubit>(
      create: (_) =>
          ProgramPeriodsCubit(getReport: _useCases.getProgramReport)..load(),
      child: ProgramReportPage(onBack: onBack, cardOf: _programCard),
    );
  }

  Widget _programCard(List<AssessmentPeriod> periods) {
    return BlocProvider<ReportExportCubit<ProgramReport>>(
      key: ValueKey<String>('program-${_keyOf(periods)}'),
      create: (_) => ReportExportCubit<ProgramReport>(
        periods: periods,
        source: ({String? fromKey, required String toKey}) => _useCases
            .getProgramReport(params: (fromKey: fromKey, toKey: toKey)),
        share: _useCases.share,
      ),
      child: Builder(
        builder: (BuildContext context) => ReportExportCard<ProgramReport>(
          title: context.l10n.classroomProgramOpen,
          hint: context.l10n.classroomProgramHint,
          periods: periods,
          rendererOf: (BuildContext context, ReportFileKind kind) {
            final ProgramReportFiles files = ProgramReportFiles(
              l10n: context.l10n,
            );
            return (ProgramReport report) => files.filesOf(report, kind);
          },
        ),
      ),
    );
  }

  static String _keyOf(List<AssessmentPeriod> periods) {
    return periods.map((AssessmentPeriod period) => period.key).join('|');
  }
}

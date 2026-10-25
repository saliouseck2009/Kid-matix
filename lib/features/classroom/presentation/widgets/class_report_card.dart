import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_state.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';

/// « Rapport de la classe »: the two periods compared and the exports in
/// PDF and CSV. No mockup: built with the design system (F31).
class ClassReportCard extends StatelessWidget {
  /// Creates the card over the [periods] of the class; the Cubit comes
  /// from the slot.
  const ClassReportCard({required this.periods, super.key});

  /// The periods of the class, the earliest first.
  final List<AssessmentPeriod> periods;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocConsumer<ClassReportCubit, ClassReportState>(
      listenWhen: (ClassReportState before, ClassReportState after) =>
          after.outcome != null && before.isBusy,
      listener: _showOutcome,
      builder: (BuildContext context, ClassReportState state) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.space12,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  context.l10n.classroomReportCardTitle,
                  style: textTheme.titleLarge,
                ),
              ),
              Text(
                context.l10n.classroomReportCardHint,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
              _PeriodChoice(periods: periods, state: state),
              _ExportButtons(isBusy: state.isBusy),
            ],
          ),
        );
      },
    );
  }

  void _showOutcome(BuildContext context, ClassReportState state) {
    final String message = state.outcome == ReportExportOutcome.shared
        ? context.l10n.classroomReportShared
        : context.l10n.classroomErrorGeneric;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PeriodChoice extends StatelessWidget {
  const _PeriodChoice({required this.periods, required this.state});

  final List<AssessmentPeriod> periods;
  final ClassReportState state;

  @override
  Widget build(BuildContext context) {
    final ClassReportCubit cubit = context.read<ClassReportCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        DropdownButtonFormField<String?>(
          initialValue: state.fromKey,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.l10n.classroomReportFrom,
          ),
          items: <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(
              child: Text(context.l10n.classroomReportNone),
            ),
            for (final AssessmentPeriod period in periods)
              DropdownMenuItem<String?>(
                value: period.key,
                child: Text(period.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (String? key) =>
              cubit.choose(fromKey: key, toKey: state.toKey),
        ),
        DropdownButtonFormField<String>(
          initialValue: state.toKey,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.l10n.classroomReportTo,
          ),
          items: <DropdownMenuItem<String>>[
            for (final AssessmentPeriod period in periods)
              DropdownMenuItem<String>(
                value: period.key,
                child: Text(period.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (String? key) {
            if (key != null) cubit.choose(fromKey: state.fromKey, toKey: key);
          },
        ),
      ],
    );
  }
}

class _ExportButtons extends StatelessWidget {
  const _ExportButtons({required this.isBusy});

  final bool isBusy;

  Future<void> _export(BuildContext context, ReportFileKind kind) {
    final ClassReportFiles files = ClassReportFiles(l10n: context.l10n);
    return context.read<ClassReportCubit>().export(
      (report) => files.filesOf(report, kind),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isBusy) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        DepthButton(
          label: context.l10n.classroomReportPdf,
          icon: Icons.picture_as_pdf_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: () => _export(context, ReportFileKind.pdf),
        ),
        DepthButton(
          label: context.l10n.classroomReportCsv,
          icon: Icons.table_chart_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: () => _export(context, ReportFileKind.csv),
        ),
      ],
    );
  }
}

/// « Rapport de la classe » before the first assessment.
class ClassReportPlaceholder extends StatelessWidget {
  /// Creates the card.
  const ClassReportPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          Text(
            context.l10n.classroomReportCardTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(context.l10n.classroomReportNeedsAssessment),
        ],
      ),
    );
  }
}

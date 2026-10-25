import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/report_export_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/report_export_state.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';

/// Makes the renderer of the files of [kind] in the language of the
/// screen.
typedef ReportRendererOf<R> = ReportRenderer<R> Function(
  BuildContext context,
  ReportFileKind kind,
);

/// A report of the teacher area: [title], [hint], the two periods
/// compared and the exports in PDF and CSV. No mockup: built with the
/// design system (F31).
class ReportExportCard<R> extends StatelessWidget {
  /// Creates the card over [periods]; the Cubit comes from the slot.
  const ReportExportCard({
    required this.title,
    required this.hint,
    required this.periods,
    required this.rendererOf,
    super.key,
  });

  /// Title of the card.
  final String title;

  /// What the report holds.
  final String hint;

  /// The periods to choose from, the earliest first.
  final List<AssessmentPeriod> periods;

  /// Makes the files.
  final ReportRendererOf<R> rendererOf;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocConsumer<ReportExportCubit<R>, ReportExportState>(
      listenWhen: (ReportExportState before, ReportExportState after) =>
          after.outcome != null && before.isBusy,
      listener: _showOutcome,
      builder: (BuildContext context, ReportExportState state) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.space12,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(title, style: textTheme.titleLarge),
              ),
              Text(
                hint,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
              _PeriodChoice<R>(periods: periods, state: state),
              if (state.isBusy)
                const Center(child: CircularProgressIndicator())
              else
                _ExportButtons<R>(rendererOf: rendererOf),
            ],
          ),
        );
      },
    );
  }

  void _showOutcome(BuildContext context, ReportExportState state) {
    final String message = state.outcome == ReportExportOutcome.shared
        ? context.l10n.classroomReportShared
        : context.l10n.classroomErrorGeneric;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PeriodChoice<R> extends StatelessWidget {
  const _PeriodChoice({required this.periods, required this.state});

  final List<AssessmentPeriod> periods;
  final ReportExportState state;

  @override
  Widget build(BuildContext context) {
    final ReportExportCubit<R> cubit = context.read<ReportExportCubit<R>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        DropdownButtonFormField<String?>(
          // initialValue is read once: a new value needs a new field.
          key: ValueKey<String?>('from-${state.fromKey}'),
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
          key: ValueKey<String>('to-${state.toKey}'),
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

class _ExportButtons<R> extends StatelessWidget {
  const _ExportButtons({required this.rendererOf});

  final ReportRendererOf<R> rendererOf;

  @override
  Widget build(BuildContext context) {
    final ReportExportCubit<R> cubit = context.read<ReportExportCubit<R>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        DepthButton(
          label: context.l10n.classroomReportPdf,
          icon: Icons.picture_as_pdf_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: () =>
              cubit.export(rendererOf(context, ReportFileKind.pdf)),
        ),
        DepthButton(
          label: context.l10n.classroomReportCsv,
          icon: Icons.table_chart_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: () =>
              cubit.export(rendererOf(context, ReportFileKind.csv)),
        ),
      ],
    );
  }
}

/// A report card before the first assessment: [title] and [message].
class ReportPlaceholderCard extends StatelessWidget {
  /// Creates the card.
  const ReportPlaceholderCard({
    required this.title,
    required this.message,
    super.key,
  });

  /// Title of the card.
  final String title;

  /// Why there is no report yet.
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(message),
        ],
      ),
    );
  }
}

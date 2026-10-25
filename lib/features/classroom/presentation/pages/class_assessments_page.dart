import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessments_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessments_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/assessments_card.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/open_assessment_dialog.dart';

/// Builds the report part of the page from the periods of the class.
typedef AssessmentReportBuilder = Widget Function(
  ClassAssessmentsOverview overview,
);

/// « Évaluations et rapports » of a class in the teacher area: its dated
/// assessments, and the reports that compare two of them. No mockup:
/// built with the design system (F31).
class ClassAssessmentsPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const ClassAssessmentsPage({
    required this.onBack,
    this.reportOf,
    super.key,
  });

  /// Goes back to the page of the class.
  final VoidCallback onBack;

  /// The reports under the assessments, or `null`.
  final AssessmentReportBuilder? reportOf;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<ClassAssessmentsCubit, ClassAssessmentsState>(
            listener: _showFailure,
            builder: (BuildContext context, ClassAssessmentsState state) {
              return switch (state) {
                ClassAssessmentsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ClassAssessmentsFailure() => Center(
                  child: Text(context.l10n.classroomErrorGeneric),
                ),
                ClassAssessmentsLoaded(:final overview) => _AssessmentsView(
                  overview: overview,
                  page: this,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  void _showFailure(BuildContext context, ClassAssessmentsState state) {
    if (state case ClassAssessmentsLoaded(failure: AppErrorCode())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.classroomErrorGeneric)),
        );
    }
  }
}

class _AssessmentsView extends StatelessWidget {
  const _AssessmentsView({required this.overview, required this.page});

  final ClassAssessmentsOverview overview;
  final ClassAssessmentsPage page;

  Future<void> _open(BuildContext context) async {
    final ClassAssessmentsCubit cubit = context.read<ClassAssessmentsCubit>();
    final String? label = await askAssessmentLabel(context);
    if (label != null) await cubit.openAssessment(label);
  }

  Future<void> _close(BuildContext context, ClassAssessment assessment) async {
    final ClassAssessmentsCubit cubit = context.read<ClassAssessmentsCubit>();
    if (await confirmAssessmentClosing(context, assessment.periodLabel)) {
      await cubit.closeAssessment(assessment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AssessmentReportBuilder? reportOf = page.reportOf;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space16,
        children: <Widget>[
          ClassroomPageHeader(
            title: context.l10n.classroomAssessmentsOpen,
            subtitle: overview.classroom.name,
            onBack: page.onBack,
          ),
          AssessmentsCard(
            overview: overview,
            onOpen: () => _open(context),
            onClose: (ClassAssessment assessment) =>
                _close(context, assessment),
          ),
          ?reportOf?.call(overview),
        ],
      ),
    );
  }
}

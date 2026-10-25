import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_rules.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessment_use_cases.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessments_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pending_assessment_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/class_assessments_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/assessment_home_banner.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_report_card.dart';

/// Builds the pages and slots of the class assessments (lot F31) for the
/// router: the teacher opens and closes them, each pupil takes the
/// placement test then the word check.
final class ClassAssessmentPages {
  /// Creates the factory.
  const ClassAssessmentPages({
    required this._useCases,
    required this._reports,
    required this._domains,
  });

  final ClassAssessmentUseCases _useCases;
  final ClassReportUseCases _reports;
  final DomainRegistry _domains;

  /// « Évaluation de la classe » at the top of the home of [profileId],
  /// while they have one to take.
  Widget buildPendingBanner({
    required String profileId,
    required ValueChanged<String> onStart,
  }) {
    return BlocProvider<PendingAssessmentCubit>(
      key: ValueKey<String>('assessment-$profileId'),
      create: (_) =>
          PendingAssessmentCubit(profileId: profileId, useCases: _useCases)
            ..load(),
      child: AssessmentHomeBanner(onStart: onStart),
    );
  }

  /// « Évaluations et rapports » at the bottom of the page of a class.
  Widget buildAssessmentsButton({required VoidCallback onOpen}) {
    return Builder(
      builder: (BuildContext context) => DepthButton(
        label: context.l10n.classroomAssessmentsOpen,
        icon: Icons.insights_rounded,
        variant: DepthButtonVariant.secondary,
        onPressed: onOpen,
      ),
    );
  }

  /// « Évaluations et rapports » of the class [classroomId].
  Widget buildAssessmentsPage({
    required String classroomId,
    required VoidCallback onBack,
  }) {
    return BlocProvider<ClassAssessmentsCubit>(
      create: (_) => ClassAssessmentsCubit(
        classroomId: classroomId,
        useCases: _useCases,
      )..load(),
      child: ClassAssessmentsPage(
        onBack: onBack,
        reportOf: (ClassAssessmentsOverview overview) =>
            _buildReportCard(classroomId, overview.periods),
      ),
    );
  }

  /// « Rapport de la classe » over the [periods] of [classroomId].
  Widget _buildReportCard(String classroomId, List<AssessmentPeriod> periods) {
    if (periods.isEmpty) return const ClassReportPlaceholder();
    return BlocProvider<ClassReportCubit>(
      key: ValueKey<String>(
        periods.map((AssessmentPeriod period) => period.key).join('|'),
      ),
      create: (_) => ClassReportCubit(
        classroomId: classroomId,
        periods: periods,
        getReport: _reports.getClassReport,
        share: _reports.share,
      ),
      child: ClassReportCard(periods: periods),
    );
  }

  /// The source key of the word check of [assessmentId].
  String wordCheckSourceKeyOf(String assessmentId) {
    return AssessmentRules.sourceKeyOf(assessmentId);
  }

  /// The word check of an assessment played for [sourceKey]: the same
  /// words every time, each heard and found among four drawings, in a
  /// random order; `null` for another quiz or without the math words.
  QuizSpec? specOf(String sourceKey) {
    if (AssessmentRules.assessmentIdOf(sourceKey) == null) return null;
    final LearningDomain? words = _domains.find(LearningDomainIds.mathWords);
    if (words == null) return null;
    return QuizSpec(
      domainId: words.id,
      mode: QuizMode.assessment,
      itemKeys: AssessmentRules.wordCheckItemKeys(words),
      questionTypeIds: const <String>[QuestionTypeIds.listenAndTouch],
      selection: QuizSelection.shuffled,
      sourceKey: sourceKey,
    );
  }
}

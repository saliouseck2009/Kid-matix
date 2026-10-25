import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pending_assessment_cubit.dart';

/// « Évaluation de la classe » at the top of the home of a pupil who still
/// has to take the assessment their teacher opened; nothing otherwise.
/// No mockup: built with the design system (F31).
class AssessmentHomeBanner extends StatelessWidget {
  /// Creates the banner; the Cubit comes from the slot.
  const AssessmentHomeBanner({required this.onStart, super.key});

  /// Starts the assessment of the given identifier.
  final ValueChanged<String> onStart;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PendingAssessmentCubit, ClassAssessment?>(
      builder: (BuildContext context, ClassAssessment? assessment) {
        if (assessment == null) return const SizedBox.shrink();
        final TextTheme textTheme = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.space16,
            AppSizes.space8,
            AppSizes.space16,
            0,
          ),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSizes.space8,
              children: <Widget>[
                Text(
                  context.l10n.classroomAssessmentBannerTitle,
                  style: textTheme.labelLarge,
                ),
                Text(assessment.periodLabel, style: textTheme.titleLarge),
                Text(context.l10n.classroomAssessmentBannerText),
                DepthButton(
                  label: context.l10n.classroomAssessmentBannerStart,
                  icon: Icons.flag_rounded,
                  onPressed: () => onStart(assessment.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

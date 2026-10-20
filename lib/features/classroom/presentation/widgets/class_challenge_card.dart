import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_challenge.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_challenge_gauge.dart';

/// The class challenge on the page of a class: the gauge, and the choice
/// of the weekly goal.
class ClassChallengeCard extends StatelessWidget {
  /// Creates the card of [challenge].
  const ClassChallengeCard({
    required this.challenge,
    required this.onGoalChanged,
    super.key,
  });

  /// The challenge of the week.
  final ClassChallenge challenge;

  /// Sets a new weekly goal.
  final ValueChanged<int> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    final List<int> choices = <int>{
      ...ClassroomRules.weeklyGoalChoices,
      challenge.goal,
    }.toList()..sort();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          ClassChallengeGauge(challenge: challenge),
          Text(
            context.l10n.classroomChallengeGoal,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          ChoiceSegments<int>(
            choices: choices,
            selected: challenge.goal,
            labelOf: (int goal) => '$goal',
            onSelected: onGoalChanged,
          ),
        ],
      ),
    );
  }
}

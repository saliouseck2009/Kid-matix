import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/training_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/training_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_error_message.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_labels.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/choice_segments.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/table_toggle.dart';

/// The training tab: the child picks tables, a question count and the
/// timer, then launches the training.
class TrainingPage extends StatelessWidget {
  /// Creates the page offering [units].
  const TrainingPage({
    required this.units,
    required this.labels,
    required this.onLaunch,
    super.key,
  });

  /// Tables to choose from, in the order shown.
  final List<LearningUnit> units;

  /// Texts of the tables.
  final ChallengeLabels labels;

  /// Starts the training chosen.
  final ValueChanged<TrainingSource> onLaunch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingCubit, TrainingState>(
      builder: (BuildContext context, TrainingState state) {
        return switch (state) {
          TrainingLoading() => const Center(child: CircularProgressIndicator()),
          TrainingFailure(:final errorCode) => Center(
            child: Text(errorCode.toChallengeMessage(context.l10n)),
          ),
          TrainingReady() => _TrainingForm(
            state: state,
            units: units,
            labels: labels,
            onLaunch: onLaunch,
          ),
        };
      },
    );
  }
}

class _TrainingForm extends StatelessWidget {
  const _TrainingForm({
    required this.state,
    required this.units,
    required this.labels,
    required this.onLaunch,
  });

  static const int _columns = 4;
  static const double _gap = 10;
  static const double _countSize = 20;

  final TrainingReady state;
  final List<LearningUnit> units;
  final ChallengeLabels labels;
  final ValueChanged<TrainingSource> onLaunch;

  Future<void> _launch(BuildContext context) async {
    final TrainingSource? choice = await context.read<TrainingCubit>().launch();
    if (choice != null) onLaunch(choice);
  }

  @override
  Widget build(BuildContext context) {
    final TrainingCubit cubit = context.read<TrainingCubit>();
    final TrainingSource choice = state.choice;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.space24,
              AppSizes.space24,
              AppSizes.space24,
              AppSizes.space16,
            ),
            children: <Widget>[
              _Title(
                title: context.l10n.trainingTitle,
                subtitle: context.l10n.trainingSubtitle,
              ),
              const SizedBox(height: AppSizes.space16),
              Column(
                spacing: _gap,
                children: <Widget>[
                  for (int start = 0; start < units.length; start += _columns)
                    Row(
                      spacing: _gap,
                      children: <Widget>[
                        for (final LearningUnit unit in units.sublist(
                          start,
                          (start + _columns).clamp(0, units.length),
                        ))
                          Expanded(
                            child: TableToggle(
                              mark: labels.unitMark(unit),
                              name: labels.unitName(unit),
                              isSelected: choice.unitKeys.contains(unit.key),
                              onTap: () => cubit.toggleUnit(unit.key),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.space16),
              _SectionTitle(text: context.l10n.trainingQuestionCountTitle),
              ChoiceSegments<int>(
                choices: ChallengeRules.trainingQuestionCounts,
                selected: choice.questionCount,
                labelOf: (int count) => '$count',
                labelStyle: textTheme.titleMedium?.copyWith(
                  fontSize: _countSize,
                ),
                onSelected: cubit.pickQuestionCount,
              ),
              const SizedBox(height: AppSizes.space16),
              _SectionTitle(text: context.l10n.trainingTimerTitle),
              ChoiceSegments<bool>(
                choices: const <bool>[true, false],
                selected: choice.hasTimer,
                labelOf: (bool hasTimer) => hasTimer
                    ? context.l10n.trainingWithTimer
                    : context.l10n.trainingWithoutTimer,
                onSelected: (bool hasTimer) =>
                    cubit.setTimer(hasTimer: hasTimer),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.space24,
            0,
            AppSizes.space24,
            AppSizes.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.space8,
            children: <Widget>[
              Text(
                state.canLaunch
                    ? context.l10n.trainingSummary(
                        choice.unitKeys.length,
                        choice.questionCount,
                      )
                    : context.l10n.trainingNoTable,
                textAlign: TextAlign.center,
                style: textTheme.labelLarge?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
              DepthButton(
                label: context.l10n.trainingLaunch,
                onPressed: state.canLaunch ? () => _launch(context) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(title, style: textTheme.headlineMedium),
        ),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.space8),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

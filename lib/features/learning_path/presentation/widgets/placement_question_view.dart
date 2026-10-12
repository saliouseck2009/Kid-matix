import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';

/// One question of the placement test: the quit cross and the progress,
/// the question card, the keypad and « Je ne sais pas ».
class PlacementQuestionView extends StatelessWidget {
  /// Creates the view of [state].
  const PlacementQuestionView({
    required this.state,
    required this.labels,
    required this.slots,
    required this.onQuit,
    super.key,
  });

  /// Question asked.
  final PlacementAsking state;

  /// Texts of the path.
  final PathLabels labels;

  /// Question card and keypad of the quiz.
  final PlacementSlots slots;

  /// Called by the quit cross.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final PlacementBloc bloc = context.read<PlacementBloc>();
    final int total = state.test.questions.length;
    final String typed = state.typedDigits;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space16,
        children: <Widget>[
          Row(
            spacing: AppSizes.space12,
            children: <Widget>[
              AppIconButton(
                icon: Icons.close_rounded,
                tooltip: context.l10n.placementQuitTooltip,
                onPressed: onQuit,
              ),
              Expanded(
                child: AppProgressBar(
                  value: state.index / total,
                  semanticLabel: context.l10n.placementQuestionProgress(
                    state.index + 1,
                    total,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: slots.questionCard(
              label: labels.unitName(state.question.unitNumber),
              prompt: state.question.question.prompt,
              typedDigits: typed.isEmpty ? null : typed,
            ),
          ),
          slots.keypad(
            onDigit: (int digit) => bloc.add(PlacementDigitTyped(digit: digit)),
            onErase: () => bloc.add(const PlacementDigitErased()),
            onValidate: typed.isEmpty || state.isSubmitting
                ? null
                : () => bloc.add(const PlacementAnswerValidated()),
          ),
          TextButton(
            onPressed: state.isSubmitting
                ? null
                : () => bloc.add(const PlacementAnswerUnknown()),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
            ),
            child: Text(context.l10n.placementUnknownAnswer),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_combo.dart';

/// Top of the quiz: the quit cross, the progress bar and the combo pill
/// once two answers in a row are right.
class QuizHeader extends StatelessWidget {
  /// Creates the header at question [current] of [total].
  const QuizHeader({
    required this.current,
    required this.answeredCount,
    required this.total,
    required this.onQuit,
    this.combo = 0,
    super.key,
  });

  /// Rank of the question shown, from 1.
  final int current;

  /// Questions already answered; they fill the bar.
  final int answeredCount;

  /// Questions of the quiz, second chances included.
  final int total;

  /// Called by the quit cross.
  final VoidCallback onQuit;

  /// Right answers in a row.
  final int combo;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: Icons.close_rounded,
          tooltip: context.l10n.quizQuitTooltip,
          onPressed: onQuit,
        ),
        Expanded(
          child: AppProgressBar(
            value: total == 0 ? 0 : answeredCount / total,
            semanticLabel: context.l10n.quizProgressLabel(current, total),
          ),
        ),
        if (combo >= QuizCombo.shownFrom)
          Semantics(
            label: context.l10n.quizComboSpoken(combo),
            excludeSemantics: true,
            child: AppPill(
              label: '$combo',
              icon: Icons.local_fire_department_rounded,
              backgroundColor: context.palette.warmTint,
            ),
          ),
      ],
    );
  }
}

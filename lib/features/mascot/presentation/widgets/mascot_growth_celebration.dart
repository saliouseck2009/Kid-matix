import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_look_of.dart';

/// Shows the growth of [mascot] to its new stage, full screen, with the
/// [feedback] of a celebration; closed by one tap.
Future<void> showMascotGrowth(
  BuildContext context,
  MascotEntity mascot, {
  required GameFeedbackService feedback,
}) {
  unawaited(feedback.play(GameFeedback.celebration));
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.rewardTapToContinue,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250),
    pageBuilder: (BuildContext dialogContext, _, _) => MascotGrowthCelebration(
      name: mascot.name,
      stage: mascot.stage,
      look: lookOf(mascot),
    ),
  );
}

/// The mascot at its new stage, happy, with its name.
class MascotGrowthCelebration extends StatelessWidget {
  /// Creates the celebration.
  const MascotGrowthCelebration({
    required this.name,
    required this.stage,
    required this.look,
    super.key,
  });

  static const double _mascotSize = 200;

  /// Name of the mascot.
  final String name;

  /// New stage.
  final int stage;

  /// Look of the mascot.
  final MascotLook look;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              spacing: AppSizes.space16,
              children: <Widget>[
                const Spacer(),
                MascotIllustration(
                  size: _mascotSize,
                  mood: MascotMood.happy,
                  look: look,
                ),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    context.l10n.mascotGrewTitle(name),
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall,
                  ),
                ),
                Text(
                  context.l10n.mascotGrewHint(stage, MascotRules.lastStage),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.rewardTapToContinue,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

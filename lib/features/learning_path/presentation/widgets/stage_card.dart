import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/star_row.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/stage_card_parts.dart';

/// One stage of the table detail: done with its stars, next with
/// "Jouer", open, locked, or the dark card of the boss fight.
class StageCard extends StatelessWidget {
  /// Creates the card of [stage].
  const StageCard({
    required this.stage,
    required this.isNext,
    required this.labels,
    required this.onPlay,
    super.key,
  });

  static const double _minHeight = 76;
  static const double _radius = 20;
  static const double _nextBorder = 3;

  /// Stage shown.
  final StageState stage;

  /// Whether it is the stage to play now, highlighted.
  final bool isNext;

  /// Texts of the path.
  final PathLabels labels;

  /// Starts the stage.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final bool isBoss = stage.kind == StageKind.boss;
    final bool isPlayable = stage.isPlayable;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = isBoss
        ? scheme.onSurface
        : isPlayable
        ? scheme.surface
        : context.palette.lockedSurface;
    return Semantics(
      button: isPlayable,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: isNext
              ? BorderSide(color: scheme.primary, width: _nextBorder)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isPlayable ? onPlay : null,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: _minHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Row(
              spacing: AppSizes.space12,
              children: <Widget>[
                StageMarker(stage: stage, isNext: isNext),
                Expanded(
                  child: StageTitle(
                    stage: stage,
                    isNext: isNext,
                    labels: labels,
                  ),
                ),
                _StageEnd(stage: stage, isNext: isNext, onPlay: onPlay),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageEnd extends StatelessWidget {
  const _StageEnd({
    required this.stage,
    required this.isNext,
    required this.onPlay,
  });

  final StageState stage;
  final bool isNext;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    if (isNext) return StagePlayButton(onPlay: onPlay);
    if (!stage.isPlayable) {
      final bool isBoss = stage.kind == StageKind.boss;
      return Icon(
        Icons.lock_outline_rounded,
        semanticLabel: stage.isComingSoon
            ? context.l10n.comingSoonMessage
            : context.l10n.pathLocked,
        color: isBoss ? context.palette.softBorder : context.palette.mutedText,
      );
    }
    if (stage.stars > 0) return StarRow(count: stage.stars);
    return const SizedBox.shrink();
  }
}

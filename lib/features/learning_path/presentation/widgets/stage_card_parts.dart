import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';

/// Round mark at the start of a stage card: a tick once done, the number
/// otherwise, a monster face for the boss.
class StageMarker extends StatelessWidget {
  /// Creates the marker of [stage].
  const StageMarker({required this.stage, required this.isNext, super.key});

  static const double _size = 40;

  /// Stage shown.
  final StageState stage;

  /// Whether it is the stage to play now.
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDone = stage.stars > 0 && !isNext;
    final (Color face, Widget child) = switch (stage) {
      StageState(kind: StageKind.boss) => (
        scheme.primary,
        Icon(Icons.face_retouching_natural_rounded, color: scheme.onPrimary),
      ),
      _ when isDone => (
        scheme.primary,
        Icon(Icons.check_rounded, color: scheme.onPrimary),
      ),
      _ => (
        isNext
            ? scheme.secondary
            : stage.isPlayable
            ? context.palette.tint
            : context.palette.lockedDepth,
        Text(
          '${stage.definition.number}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: stage.isPlayable
                ? scheme.onSurface
                : context.palette.mutedText,
          ),
        ),
      ),
    };
    return ExcludeSemantics(
      child: Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: face, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

/// Name and description of a stage: "1 · Découverte", "La table et son
/// astuce"; the next stage shows its name alone, as its marker gives the
/// number.
class StageTitle extends StatelessWidget {
  /// Creates the title of [stage].
  const StageTitle({
    required this.stage,
    required this.isNext,
    required this.labels,
    super.key,
  });

  /// Stage shown.
  final StageState stage;

  /// Whether it is the stage to play now.
  final bool isNext;

  /// Texts of the path.
  final PathLabels labels;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isBoss = stage.kind == StageKind.boss;
    final String name = labels.stageName(stage.kind);
    final bool showsNumber = !isNext && (stage.stars > 0 || isBoss);
    final Color titleColor = isBoss
        ? Theme.of(context).colorScheme.surface
        : stage.isPlayable
        ? Theme.of(context).colorScheme.onSurface
        : context.palette.mutedText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          showsNumber
              ? context.l10n.pathStageNumbered(stage.definition.number, name)
              : name,
          style: textTheme.titleMedium?.copyWith(color: titleColor),
        ),
        Text(
          labels.stageHint(stage.kind),
          style: textTheme.bodyMedium?.copyWith(
            color: isBoss
                ? context.palette.softBorder
                : context.palette.mutedText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// "Jouer" button of the next stage.
class StagePlayButton extends StatelessWidget {
  /// Creates the button.
  const StagePlayButton({required this.onPlay, super.key});

  static const double _depth = 5;
  static const double _radius = 16;

  /// Starts the stage.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(_radius);
    return Container(
      padding: const EdgeInsets.only(bottom: _depth),
      decoration: BoxDecoration(
        color: context.palette.primaryDepth,
        borderRadius: radius,
      ),
      child: Material(
        color: scheme.primary,
        borderRadius: radius,
        child: InkWell(
          onTap: onPlay,
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Text(
              context.l10n.pathPlay,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: scheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

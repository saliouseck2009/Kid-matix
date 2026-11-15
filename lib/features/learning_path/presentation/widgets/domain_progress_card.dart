import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/core/widgets/crown_mark.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_progress_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_mark.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/raised_tile.dart';

/// One domain in « Mes parcours »: its tile and name, a badge (« En
/// cours », « Terminé » or « Conseillé »), the units done and the crowns,
/// or « Pas encore commencé ».
class DomainProgressCard extends StatelessWidget {
  /// Creates the card of [progress].
  const DomainProgressCard({
    required this.progress,
    required this.isCurrent,
    required this.isRecommended,
    required this.onTap,
    super.key,
  });

  /// Progress in the domain.
  final DomainProgressEntity progress;

  /// Whether the domain is the one shown on the map.
  final bool isCurrent;

  /// Whether the latest placement test recommended the domain.
  final bool isRecommended;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Width and height of the domain tile.
  static const double markSize = 52;

  /// Height of the progress bar, thinner than the default one.
  static const double barHeight = 10;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String domainId = progress.domainId;
    return Semantics(
      selected: isCurrent,
      child: RaisedTile(
        onTap: onTap,
        outline: isCurrent ? scheme.primary : context.palette.border,
        depth: isCurrent
            ? context.palette.primaryDepth
            : context.palette.border,
        child: MergeSemantics(
          child: Row(
            spacing: AppSizes.space12,
            children: <Widget>[
              DomainMark(domainId: domainId, size: markSize),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSizes.space4,
                  children: <Widget>[
                    Wrap(
                      spacing: AppSizes.space8,
                      runSpacing: AppSizes.space4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Semantics(
                          label: context.l10n.domainSpokenName(domainId),
                          excludeSemantics: true,
                          child: Text(
                            context.l10n.domainName(domainId),
                            style: textTheme.titleMedium,
                          ),
                        ),
                        ?_badge(context),
                      ],
                    ),
                    if (progress.isStarted)
                      _UnitsRow(progress: progress)
                    else
                      Text(
                        context.l10n.pathPickerNotStarted,
                        style: textTheme.bodySmall?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                  ],
                ),
              ),
              if (progress.isStarted)
                Semantics(
                  label: context.l10n.pathCrownsSpoken(progress.crownCount),
                  excludeSemantics: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space8,
                      vertical: AppSizes.space4,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.warmTint,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusPill,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSizes.space4,
                      children: <Widget>[
                        CrownGlyph(color: scheme.onSurface),
                        Text(
                          '${progress.crownCount}',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// « En cours », else « Terminé », else « Conseillé », else nothing.
  Widget? _badge(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppFeedbackPalette feedback = context.feedbackPalette;
    if (isCurrent) {
      return _Badge(
        label: context.l10n.pathPickerCurrent,
        icon: Icons.check_rounded,
        background: scheme.primary,
        foreground: scheme.onPrimary,
      );
    }
    if (progress.isFinished) {
      return _Badge(
        label: context.l10n.pathPickerFinished,
        background: feedback.rightTint,
        foreground: feedback.rightDepth,
      );
    }
    if (isRecommended) {
      return _Badge(
        label: context.l10n.pathPickerRecommended,
        icon: Icons.star_rounded,
        background: scheme.secondary,
        foreground: scheme.onSecondary,
      );
    }
    return null;
  }
}

/// The bar of the units done and « 7 / 12 ».
class _UnitsRow extends StatelessWidget {
  const _UnitsRow({required this.progress});

  final DomainProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final Color color = progress.isFinished
        ? context.feedbackPalette.right
        : Theme.of(context).colorScheme.primary;
    final String spoken = context.l10n.pathPickerUnitsSpoken(
      progress.doneUnitCount,
      progress.unitCount,
    );
    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: Row(
        spacing: AppSizes.space8,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: DomainProgressCard.barHeight,
              child: AppProgressBar(
                value: progress.doneFraction.clamp(0, 1),
                semanticLabel: spoken,
                color: color,
              ),
            ),
          ),
          Text(
            context.l10n.pathPickerUnits(
              progress.doneUnitCount,
              progress.unitCount,
            ),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: progress.isFinished ? color : context.palette.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small colored badge, such as « En cours ».
class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  static const double _iconSize = 14;
  static const double _verticalPadding = 2;

  @override
  Widget build(BuildContext context) {
    final IconData? icon = this.icon;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space8,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSizes.space4,
        children: <Widget>[
          if (icon != null) Icon(icon, size: _iconSize, color: foreground),
          // A long label at a large text size wraps instead of overflowing.
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

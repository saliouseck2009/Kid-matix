import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';

/// "Mes badges" on the Profile tab: the badges of the launch, earned ones
/// in color and the others grayed with how to earn them, then the tamer
/// badges won.
class BadgesCard extends StatelessWidget {
  /// Creates the card; the badges come from the enclosing Cubit.
  const BadgesCard({required this.labels, super.key});

  /// Badges always shown, earned or not.
  static const List<String> launchBadges = <String>[
    BadgeKey.firstStep,
    BadgeKey.perfect,
    BadgeKey.lightning,
    BadgeKey.sprinter,
    BadgeKey.regular,
    BadgeKey.allFacts,
  ];

  static const int _columns = 3;
  static const double _gap = 10;
  static const double _radius = 20;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 14,
  );

  /// Names and hints of the badges.
  final BadgeLabels labels;

  @override
  Widget build(BuildContext context) {
    final List<BadgeUnlockEntity>? unlocked = switch (context
        .watch<RewardValueCubit<List<BadgeUnlockEntity>>>()
        .state) {
      RewardValueLoaded<List<BadgeUnlockEntity>>(:final value) => value,
      _ => null,
    };
    if (unlocked == null) return const SizedBox.shrink();
    final Set<String> earned = <String>{
      for (final BadgeUnlockEntity badge in unlocked) badge.badgeKey,
    };
    final List<String> shown = <String>[
      ...launchBadges,
      ...earned.where((String key) => BadgeKey.unitOfTamer(key) != null),
    ];
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space12,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.l10n.rewardBadgesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width =
                  (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
              return Wrap(
                spacing: _gap,
                runSpacing: _gap,
                children: <Widget>[
                  for (final String key in shown)
                    SizedBox(
                      width: width,
                      child: _BadgeTile(
                        name: labels.nameOf(key),
                        hint: labels.hintOf(key),
                        icon: _iconOf(key),
                        isEarned: earned.contains(key),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static IconData _iconOf(String key) {
    return switch (key) {
      BadgeKey.firstStep => Icons.flag_rounded,
      BadgeKey.perfect => Icons.verified_rounded,
      BadgeKey.lightning => Icons.bolt_rounded,
      BadgeKey.sprinter => Icons.timer_rounded,
      BadgeKey.regular => Icons.local_fire_department_rounded,
      BadgeKey.allFacts => Icons.emoji_events_rounded,
      _ => Icons.military_tech_rounded,
    };
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.name,
    required this.hint,
    required this.icon,
    required this.isEarned,
  });

  static const double _circle = 48;
  static const double _iconSize = 28;

  final String name;
  final String hint;
  final IconData icon;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: isEarned
          ? context.l10n.rewardBadgeEarnedSpoken(name)
          : context.l10n.rewardBadgeLockedSpoken(name, hint),
      excludeSemantics: true,
      child: Column(
        spacing: AppSizes.space4,
        children: <Widget>[
          Container(
            width: _circle,
            height: _circle,
            decoration: BoxDecoration(
              color: isEarned
                  ? context.palette.warmTint
                  : context.palette.lockedSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? icon : Icons.lock_rounded,
              size: _iconSize,
              color: isEarned ? scheme.primary : context.palette.lockedDepth,
            ),
          ),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isEarned ? null : context.palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

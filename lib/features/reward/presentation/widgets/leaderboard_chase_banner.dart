import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_chase.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// The mascot at the bottom of the leaderboard, telling the active player
/// how far the player above is (mockup 19).
class LeaderboardChaseBanner extends StatelessWidget {
  /// Creates the banner for [chase].
  const LeaderboardChaseBanner({required this.chase, super.key});

  static const double _radius = 24;
  static const double _mascotSize = 64;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 14,
  );

  /// Where the active player stands.
  final LeaderboardChase chase;

  /// Returns what the mascot says for [chase].
  static String messageOf(AppLocalizations l10n, LeaderboardChase chase) {
    return switch (chase) {
      LeaderboardChaseBehind(:final nickname, :final missingXp) =>
        l10n.leaderboardChaseBehind(missingXp, nickname),
      LeaderboardChaseTied(:final nickname) => l10n.leaderboardChaseTied(
        nickname,
      ),
      LeaderboardChaseLeading() => l10n.leaderboardChaseLeading,
      LeaderboardChaseNotStarted() => l10n.leaderboardChaseNotStarted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.palette.warmTint,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          MascotIllustration(
            size: _mascotSize,
            mood: chase is LeaderboardChaseLeading
                ? MascotMood.happy
                : MascotMood.encouraging,
          ),
          Expanded(
            child: Text(
              messageOf(context.l10n, chase),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

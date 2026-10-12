import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/crown_mark.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_share_button.dart';

/// The end of a game replayed from a code: won, lost or tied, the score
/// to beat beside the child's, the difference and the XP, then
/// « Renvoyer un défi » and « Retour aux défis » (mockup 21). Needs a
/// `ChallengeShareCubit` above it.
class CodeOutcomeView extends StatelessWidget {
  /// Creates the view.
  const CodeOutcomeView({
    required this.subtitle,
    required this.scoreToBeat,
    required this.score,
    required this.sourceKey,
    required this.onShare,
    required this.onBack,
    this.xpLabel,
    this.recordCard,
    super.key,
  });

  static const double _mascotSize = 140;

  /// The mode and the tables, such as "Contre-la-montre · tables de 2 et
  /// de 5".
  final String subtitle;

  /// Right answers written in the code.
  final int scoreToBeat;

  /// Right answers of the child.
  final int score;

  /// Source key of the game, to send the challenge back.
  final String sourceKey;

  /// Opens the code sent back.
  final ValueChanged<String> onShare;

  /// Goes back to the challenges.
  final VoidCallback onBack;

  /// The XP earned, such as "+210 XP", or `null`.
  final Widget? xpLabel;

  /// A new record, or `null`.
  final Widget? recordCard;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isWon = score > scoreToBeat;
    final bool isLost = score < scoreToBeat;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: <Widget>[
          Center(
            child: MascotIllustration(
              size: _mascotSize,
              mood: isLost ? MascotMood.encouraging : MascotMood.happy,
            ),
          ),
          Column(
            spacing: AppSizes.space4,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  isWon
                      ? context.l10n.challengeOutcomeWon
                      : isLost
                      ? context.l10n.challengeOutcomeLost
                      : context.l10n.challengeOutcomeTie,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(fontSize: 32),
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
          _ScoreCards(scoreToBeat: scoreToBeat, score: score, isWon: isWon),
          _DifferenceBand(
            difference: score - scoreToBeat,
            xpLabel: xpLabel,
          ),
          ?recordCard,
          const SizedBox(height: AppSizes.space8),
          ChallengeShareButton(
            label: context.l10n.challengeOutcomeResend,
            variant: DepthButtonVariant.primary,
            sourceKey: sourceKey,
            score: score,
            onShare: onShare,
          ),
          DepthButton(
            label: context.l10n.challengeOutcomeBack,
            variant: DepthButtonVariant.secondary,
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

/// « Score à battre » in white beside « Ton score » in violet, crowned
/// when the child won.
class _ScoreCards extends StatelessWidget {
  const _ScoreCards({
    required this.scoreToBeat,
    required this.score,
    required this.isWon,
  });

  final int scoreToBeat;
  final int score;
  final bool isWon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: AppSizes.space12,
      children: <Widget>[
        Expanded(
          child: _ScoreCard(
            label: context.l10n.challengeOutcomeToBeat,
            score: scoreToBeat,
            background: scheme.surface,
            textColor: scheme.onSurface,
            mutedColor: context.palette.mutedText,
          ),
        ),
        Expanded(
          child: _ScoreCard(
            label: context.l10n.challengeOutcomeYours,
            score: score,
            background: scheme.primary,
            depth: context.palette.primaryDepth,
            textColor: scheme.onPrimary,
            mutedColor: scheme.onPrimary,
            crown: isWon ? CrownGlyph(color: scheme.secondary, size: 32) : null,
            scoreSize: 72,
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.background,
    required this.textColor,
    required this.mutedColor,
    this.depth,
    this.crown,
    this.scoreSize = 64,
  });

  static const double _radius = 24;
  static const double _depthWidth = 7;

  final String label;
  final int score;
  final Color background;
  final Color textColor;
  final Color mutedColor;
  final Color? depth;
  final Widget? crown;
  final double scoreSize;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color? depth = this.depth;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_radius),
        border: depth == null
            ? null
            : Border(
                bottom: BorderSide(color: depth, width: _depthWidth),
              ),
      ),
      child: MergeSemantics(
        child: Column(
          spacing: 2,
          children: <Widget>[
            ?crown,
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(color: mutedColor),
            ),
            FittedBox(
              child: Text(
                '$score',
                style: textTheme.displaySmall?.copyWith(
                  fontSize: scoreSize,
                  height: 1.1,
                  color: textColor,
                ),
              ),
            ),
            Text(
              context.l10n.challengeOutcomeCorrect(score),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: mutedColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The yellow band: how many right answers more or fewer, and the XP.
class _DifferenceBand extends StatelessWidget {
  const _DifferenceBand({required this.difference, required this.xpLabel});

  static const double _radius = 20;

  final int difference;
  final Widget? xpLabel;

  @override
  Widget build(BuildContext context) {
    final Widget? xp = xpLabel;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: context.palette.warmTint,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          Expanded(
            child: Text(
              difference > 0
                  ? context.l10n.challengeOutcomeMore(difference)
                  : difference < 0
                  ? context.l10n.challengeOutcomeFewer(-difference)
                  : context.l10n.challengeOutcomeSame,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          ?xp,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/survival_challenge_entity.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenges_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenges_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_card.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_error_message.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/daily_review_card.dart';

/// The challenges tab: the daily review, then each challenge with the
/// player's record.
class ChallengesPage extends StatelessWidget {
  /// Creates the page.
  const ChallengesPage({required this.onPlay, super.key});

  static const double _cardGap = 10;

  /// Starts a challenge.
  final ValueChanged<ChallengeSource> onPlay;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengesCubit, ChallengesState>(
      builder: (BuildContext context, ChallengesState state) {
        return ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.challengesTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            switch (state) {
              ChallengesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ChallengesFailure(:final errorCode) => Text(
                errorCode.toChallengeMessage(context.l10n),
              ),
              ChallengesLoaded(
                :final timeAttack,
                :final survival,
                :final records,
                :final review,
              ) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _cardGap,
                  children: <Widget>[
                    _DailyReview(
                      review: review,
                      onPlay: () => onPlay(DailyReviewSource()),
                    ),
                    ChallengeCard(
                      icon: Icons.timer_outlined,
                      iconBackground: context.palette.warmTint,
                      title: context.l10n.quizModeTimeAttack,
                      subtitle: context.l10n.challengeTimeAttackSubtitle,
                      record: _recordOf(context, records[QuizMode.timeAttack]),
                      onTap: () => onPlay(timeAttack),
                    ),
                    _SurvivalCard(
                      survival: survival,
                      record: _recordOf(context, records[QuizMode.survival]),
                      onPlay: onPlay,
                    ),
                  ],
                ),
            },
          ],
        );
      },
    );
  }

  static String? _recordOf(BuildContext context, RecordEntity? record) {
    return record == null
        ? null
        : context.l10n.challengeRecord(record.bestScore);
  }
}

class _SurvivalCard extends StatelessWidget {
  const _SurvivalCard({
    required this.survival,
    required this.record,
    required this.onPlay,
  });

  final SurvivalChallengeEntity survival;
  final String? record;
  final ValueChanged<ChallengeSource> onPlay;

  @override
  Widget build(BuildContext context) {
    return ChallengeCard(
      icon: Icons.favorite_rounded,
      iconColor: context.feedbackPalette.wrong,
      iconBackground: context.feedbackPalette.wrongTint,
      title: context.l10n.quizModeSurvival,
      subtitle: context.l10n.challengeSurvivalSubtitle,
      note: survival.keepsTimerTurnedOff
          ? context.l10n.challengeSurvivalTimerNote
          : null,
      record: record,
      onTap: () => onPlay(survival.source),
    );
  }
}

/// The daily review card of [review]: open once the player has seen a
/// fact, with the count of facts due when there are some.
class _DailyReview extends StatelessWidget {
  const _DailyReview({required this.review, required this.onPlay});

  final ReviewOverview review;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final bool isOpen = review.hasSeenItems;
    return DailyReviewCard(
      title: context.l10n.quizModeDailyReview,
      subtitle: isOpen
          ? context.l10n.challengeDailyReviewSubtitle(
              ChallengeRules.dailyReviewQuestionCount,
            )
          : context.l10n.challengeDailyReviewLocked,
      dueLabel: isOpen && review.dueCount > 0
          ? context.l10n.challengeDailyReviewDue(review.dueCount)
          : null,
      onTap: isOpen ? onPlay : null,
    );
  }
}

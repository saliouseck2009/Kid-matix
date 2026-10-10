import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenges_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenges_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_card.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_error_message.dart';

/// The challenges tab: each challenge with the player's record. Version
/// 1.0 has the time attack; the other challenges come with version 1.1.
class ChallengesPage extends StatelessWidget {
  /// Creates the page.
  const ChallengesPage({required this.onPlay, super.key});

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
              ChallengesLoaded(:final timeAttack, :final records) =>
                ChallengeCard(
                  icon: Icons.timer_outlined,
                  iconBackground: context.palette.warmTint,
                  title: context.l10n.quizModeTimeAttack,
                  subtitle: context.l10n.challengeTimeAttackSubtitle,
                  record: switch (records[QuizMode.timeAttack]) {
                    final RecordEntity record => context.l10n.challengeRecord(
                      record.bestScore,
                    ),
                    null => null,
                  },
                  onTap: () => onPlay(timeAttack),
                ),
            },
          ],
        );
      },
    );
  }
}

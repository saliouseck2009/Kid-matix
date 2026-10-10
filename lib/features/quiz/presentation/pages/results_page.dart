import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/widgets/star_row.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/results_cubit.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/results_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/facts_to_review_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_session_error_message.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/result_tile.dart';

/// Names what a session was played for from its source key, or `null`.
typedef SourceDescriber = String? Function(
  String? sourceKey,
  AppLocalizations l10n,
);

/// Results of a quiz, loaded from the session identifier alone.
///
/// A stage of the learning path shows its stars; XP and level arrive
/// with the rewards (F7).
class ResultsPage extends StatelessWidget {
  /// Creates the results of the session [sessionId].
  const ResultsPage({
    required this.sessionId,
    required this.getResult,
    required this.domains,
    required this.onContinue,
    required this.onReplay,
    this.describeSource,
    this.rewardsScope,
    this.xpTile,
    this.rewardsCard,
    super.key,
  });

  /// Identifier of the saved session.
  final String sessionId;

  /// Reads the session.
  final GetQuizResultUseCase getResult;

  /// Learning domains, to name units and facts.
  final DomainRegistry domains;

  /// Called by "Continuer" with the source key of the session, to go back
  /// where the quiz was started.
  final ValueChanged<String?> onContinue;

  /// Called by "Rejouer" with the source key of the session; the button
  /// shows only for a quiz played for a source.
  final ValueChanged<String> onReplay;

  /// Names what a session was played for, such as "Entraînement" for a
  /// stage, or `null` to name its mode.
  final SourceDescriber? describeSource;

  /// Wraps the page to provide the rewards of the quiz, or `null`.
  final Widget Function(Widget child)? rewardsScope;

  /// First tile of the results: the XP earned, or `null`.
  final Widget? xpTile;

  /// Card under the tiles: the level and the new badges, or `null`.
  final Widget? rewardsCard;

  @override
  Widget build(BuildContext context) {
    final Widget Function(Widget child) scope =
        rewardsScope ?? (Widget child) => child;
    return BlocProvider<ResultsCubit>(
      create: (_) =>
          ResultsCubit(sessionId: sessionId, getResult: getResult)..load(),
      child: scope(
        Scaffold(
          body: SafeArea(
            child: BlocBuilder<ResultsCubit, ResultsState>(
              builder: (BuildContext context, ResultsState state) {
                return switch (state) {
                  ResultsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ResultsFailure(:final errorCode) => Center(
                    child: Text(errorCode.toQuizMessage(context.l10n)),
                  ),
                  ResultsLoaded(:final result) => _ResultsView(
                    result: result,
                    labels: QuizLabels(domains: domains, l10n: context.l10n),
                    onContinue: onContinue,
                    onReplay: onReplay,
                    describeSource: describeSource,
                    xpTile: xpTile,
                    rewardsCard: rewardsCard,
                  ),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.result,
    required this.labels,
    required this.onContinue,
    required this.onReplay,
    required this.describeSource,
    required this.xpTile,
    required this.rewardsCard,
  });

  static const double _mascotSize = 140;
  static const double _starSize = 64;

  final QuizResultEntity result;
  final QuizLabels labels;
  final ValueChanged<String?> onContinue;
  final ValueChanged<String> onReplay;
  final SourceDescriber? describeSource;
  final Widget? xpTile;
  final Widget? rewardsCard;

  @override
  Widget build(BuildContext context) {
    final Widget? rewards = rewardsCard;
    final String domainId = result.session.domainId;
    final int? stars = result.stars;
    final String? sourceKey = result.session.sourceKey;
    final LearningUnit? unit = labels.findCommonUnit(
      result.askedItemKeys,
      domainId,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space16,
        children: <Widget>[
          const Center(
            child: MascotIllustration(
              size: _mascotSize,
              mood: MascotMood.happy,
            ),
          ),
          _ResultsTitle(
            title: switch (result.session.bossOutcome) {
              BossOutcome.defeated => context.l10n.resultsBossDefeated,
              BossOutcome.fled => context.l10n.resultsBossFled,
              null when stars != null => context.l10n.resultsStageTitle,
              null => context.l10n.resultsTitle,
            },
            subtitle: unit == null
                ? _describeMode(context)
                : context.l10n.resultsSubtitle(
                    labels.describeUnit(unit, domainId),
                    _describeMode(context),
                  ),
          ),
          if (stars != null)
            Center(
              child: StarRow(count: stars, size: _starSize),
            ),
          _ResultTiles(result: result, xpTile: xpTile),
          ?rewards,
          FactsToReviewCard(
            facts: <String>[
              for (final String key in result.missedItemKeys)
                labels.describeItem(key, domainId),
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          DepthButton(
            label: context.l10n.resultsContinue,
            onPressed: () => onContinue(sourceKey),
          ),
          if (sourceKey != null)
            DepthButton(
              label: context.l10n.resultsReplay,
              variant: DepthButtonVariant.secondary,
              onPressed: () => onReplay(sourceKey),
            ),
        ],
      ),
    );
  }

  String _describeMode(BuildContext context) {
    final String? source = describeSource?.call(
      result.session.sourceKey,
      context.l10n,
    );
    if (source != null) return source;
    return switch (result.session.mode) {
      QuizMode.freeTraining => context.l10n.quizModeFreeTraining,
      QuizMode.path => context.l10n.quizModePath,
      QuizMode.timeAttack => context.l10n.quizModeTimeAttack,
    };
  }
}

class _ResultsTitle extends StatelessWidget {
  const _ResultsTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
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
    );
  }
}

class _ResultTiles extends StatelessWidget {
  const _ResultTiles({required this.result, required this.xpTile});

  static const int _millisecondsPerSecond = 1000;

  final QuizResultEntity result;
  final Widget? xpTile;

  @override
  Widget build(BuildContext context) {
    final Duration? average = result.averageAnswerTime;
    final int correct = result.session.correctCount;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        if (xpTile case final Widget tile) Expanded(child: tile),
        Expanded(
          child: ResultTile(
            value: context.l10n.resultsCorrectCount(
              correct,
              result.session.questionCount,
            ),
            label: context.l10n.resultsCorrectLabel(correct),
          ),
        ),
        if (average != null)
          Expanded(
            child: ResultTile(
              value: context.l10n.resultsAverageTime(
                average.inMilliseconds / _millisecondsPerSecond,
              ),
              label: context.l10n.resultsAverageTimeLabel,
            ),
          ),
      ],
    );
  }
}

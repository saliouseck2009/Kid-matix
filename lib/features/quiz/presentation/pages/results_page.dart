import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/widgets/pinned_actions.dart';
import 'package:kid_matix/core/widgets/star_row.dart';
import 'package:kid_matix/core/widgets/stat_tile.dart';
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

/// Names what a session was played for from its source key, or `null`.
typedef SourceDescriber = String? Function(
  String? sourceKey,
  AppLocalizations l10n,
);

/// A widget of the results built from what the session was played for
/// and its right answers, or `null` to show nothing.
typedef SessionScoreSlot = Widget? Function(
  String? sourceKey,
  int correctCount,
);

/// Wraps the buttons of the results for what the session was played for:
/// [builder] gets the callback that starts what comes next, such as the
/// next stage of the path, or `null` when nothing does. `null` when the
/// session has nothing next.
typedef SessionNextSlot = Widget? Function(
  String? sourceKey,
  Widget Function(VoidCallback? onNext) builder,
);

/// Results of a quiz, loaded from the session identifier alone.
///
/// A stage of the learning path shows its stars; XP and level arrive
/// with the rewards (F7). The buttons stay at the bottom, on two rows at
/// most, while the rest scrolls.
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
    this.recordCard,
    this.actionOf,
    this.outcomeOf,
    this.nextOf,
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

  /// Card above the tiles: a new record, or `null`.
  final Widget? recordCard;

  /// A last button beside "Rejouer", such as "Défier un ami", or `null`.
  final SessionScoreSlot? actionOf;

  /// A screen that replaces the results, such as the comparison of a
  /// challenge played from a code, or `null`.
  final SessionScoreSlot? outcomeOf;

  /// Tells whether something comes next, such as the next stage of the
  /// path, started by "Étape suivante"; or `null`.
  final SessionNextSlot? nextOf;

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
                  ResultsLoaded(:final result) =>
                    outcomeOf?.call(
                          result.session.sourceKey,
                          result.session.correctCount,
                        ) ??
                        _ResultsView(
                          result: result,
                          labels: QuizLabels(
                            domains: domains,
                            l10n: context.l10n,
                          ),
                          onContinue: onContinue,
                          onReplay: onReplay,
                          describeSource: describeSource,
                          xpTile: xpTile,
                          rewardsCard: rewardsCard,
                          recordCard: recordCard,
                          nextOf: nextOf,
                          action: actionOf?.call(
                            result.session.sourceKey,
                            result.session.correctCount,
                          ),
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
    required this.recordCard,
    required this.nextOf,
    required this.action,
  });

  static const double _mascotSize = 96;
  static const double _starSize = 64;

  final QuizResultEntity result;
  final QuizLabels labels;
  final ValueChanged<String?> onContinue;
  final ValueChanged<String> onReplay;
  final SourceDescriber? describeSource;
  final Widget? xpTile;
  final Widget? rewardsCard;
  final Widget? recordCard;
  final SessionNextSlot? nextOf;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final Widget? rewards = rewardsCard;
    final Widget? record = recordCard;
    final String domainId = result.session.domainId;
    final int? stars = result.stars;
    final String? sourceKey = result.session.sourceKey;
    final LearningUnit? unit = labels.findCommonUnit(
      result.askedItemKeys,
      domainId,
    );
    return PinnedActions(
      actions:
          nextOf?.call(sourceKey, (VoidCallback? onNext) {
            return _actions(context, onNext);
          }) ??
          _actions(context, null),
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
                    context.l10n.unitName(domainId, unit.key),
                    _describeMode(context),
                  ),
          ),
          if (stars != null)
            Center(
              child: StarRow(count: stars, size: _starSize),
            ),
          ?record,
          _ResultTiles(result: result, xpTile: xpTile),
          FactsToReviewCard(
            facts: <String>[
              for (final String key in result.missedItemKeys)
                labels.describeItem(key, domainId),
            ],
          ),
          ?rewards,
        ],
      ),
    );
  }

  /// The buttons: what comes next or "Continuer" on the whole width, then
  /// "Rejouer" beside the way back or the last button of the session.
  Widget _actions(BuildContext context, VoidCallback? onNext) {
    final String? sourceKey = result.session.sourceKey;
    final Widget? action = this.action;
    void goBack() => onContinue(sourceKey);
    return ActionRows(
      primary: onNext == null
          ? DepthButton(
              label: context.l10n.resultsContinue,
              onPressed: goBack,
            )
          : DepthButton(
              label: context.l10n.resultsNextStage,
              onPressed: onNext,
            ),
      secondary: <Widget>[
        if (sourceKey != null)
          DepthButton(
            label: context.l10n.resultsReplay,
            variant: DepthButtonVariant.secondary,
            onPressed: () => onReplay(sourceKey),
          ),
        if (onNext != null)
          DepthButton(
            label: context.l10n.resultsBackToPath,
            variant: DepthButtonVariant.secondary,
            onPressed: goBack,
          )
        else
          ?action,
      ],
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
      QuizMode.survival => context.l10n.quizModeSurvival,
      QuizMode.dailyReview => context.l10n.quizModeDailyReview,
      QuizMode.monsterHunt => context.l10n.quizModeMonsterHunt,
      QuizMode.assessment => context.l10n.quizModeAssessment,
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
    return StatTileRow(
      tiles: <Widget>[
        ?xpTile,
        StatTile(
          value: context.l10n.resultsCorrectCount(
            correct,
            result.session.questionCount,
          ),
          label: context.l10n.resultsCorrectLabel(correct),
        ),
        if (average != null)
          StatTile(
            value: context.l10n.resultsAverageTime(
              average.inMilliseconds / _millisecondsPerSecond,
            ),
            label: context.l10n.resultsAverageTimeLabel,
          ),
      ],
    );
  }
}

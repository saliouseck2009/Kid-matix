import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/results_cubit.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/results_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/facts_to_review_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_session_error_message.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/result_tile.dart';

/// Results of a quiz, loaded from the session identifier alone.
///
/// Stars arrive with the learning path (F5), XP and level with the rewards
/// (F7).
class ResultsPage extends StatelessWidget {
  /// Creates the results of the session [sessionId].
  const ResultsPage({
    required this.sessionId,
    required this.getResult,
    required this.domains,
    required this.onContinue,
    required this.onReplay,
    super.key,
  });

  /// Identifier of the saved session.
  final String sessionId;

  /// Reads the session.
  final GetQuizResultUseCase getResult;

  /// Learning domains, to name units and facts.
  final DomainRegistry domains;

  /// Called by "Continuer".
  final VoidCallback onContinue;

  /// Called by "Rejouer" with the unit to play again.
  final ValueChanged<String> onReplay;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResultsCubit>(
      create: (_) =>
          ResultsCubit(sessionId: sessionId, getResult: getResult)..load(),
      child: Scaffold(
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
                ),
              };
            },
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
  });

  static const double _mascotSize = 140;

  final QuizResultEntity result;
  final QuizLabels labels;
  final VoidCallback onContinue;
  final ValueChanged<String> onReplay;

  @override
  Widget build(BuildContext context) {
    final String domainId = result.session.domainId;
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
          const Center(child: MascotIllustration(size: _mascotSize)),
          _ResultsTitle(
            subtitle: unit == null
                ? _describeMode(context, result.session.mode)
                : context.l10n.resultsSubtitle(
                    labels.describeUnit(unit, domainId),
                    _describeMode(context, result.session.mode),
                  ),
          ),
          _ResultTiles(result: result),
          FactsToReviewCard(
            facts: <String>[
              for (final String key in result.missedItemKeys)
                labels.describeItem(key, domainId),
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          DepthButton(
            label: context.l10n.resultsContinue,
            onPressed: onContinue,
          ),
          if (unit != null)
            DepthButton(
              label: context.l10n.resultsReplay,
              variant: DepthButtonVariant.secondary,
              onPressed: () => onReplay(unit.key),
            ),
        ],
      ),
    );
  }

  static String _describeMode(BuildContext context, QuizMode mode) {
    return switch (mode) {
      QuizMode.freeTraining => context.l10n.quizModeFreeTraining,
      QuizMode.path => context.l10n.quizModePath,
    };
  }
}

class _ResultsTitle extends StatelessWidget {
  const _ResultsTitle({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            context.l10n.resultsTitle,
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
  const _ResultTiles({required this.result});

  static const int _millisecondsPerSecond = 1000;

  final QuizResultEntity result;

  @override
  Widget build(BuildContext context) {
    final Duration? average = result.averageAnswerTime;
    final int correct = result.session.correctCount;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
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

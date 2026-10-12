import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_bloc.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_event.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_error_message.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_arena.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_pause_dialog.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_player_picker.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_result_view.dart';

/// The duel on one phone, full screen without the tab bar: the choice of
/// the players, the race, then the winner.
class DuelPage extends StatelessWidget {
  /// Creates the page.
  const DuelPage({
    required this.avatarOf,
    required this.feedback,
    required this.onClose,
    super.key,
  });

  /// Draws the avatar of a profile.
  final DuelAvatarBuilder avatarOf;

  /// Sound and vibration of each answer and of the victory.
  final GameFeedbackService feedback;

  /// Leaves the duel.
  final VoidCallback onClose;

  Future<void> _pause(BuildContext context) async {
    final DuelBloc bloc = context.read<DuelBloc>();
    if (await showDuelPause(context)) bloc.add(const DuelAbandoned());
  }

  void _goBack(BuildContext context) {
    if (context.read<DuelBloc>().state is DuelRunning) {
      unawaited(_pause(context));
    } else {
      onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _goBack(context);
      },
      child: BlocListener<DuelBloc, DuelState>(
        listenWhen: _isFeedbackDue,
        listener: (BuildContext context, DuelState state) {
          unawaited(feedback.play(_feedbackOf(state)));
        },
        child: Scaffold(
          body: BlocBuilder<DuelBloc, DuelState>(
            builder: (BuildContext context, DuelState state) => _DuelBody(
              state: state,
              avatarOf: avatarOf,
              onPause: () => _pause(context),
              onClose: onClose,
            ),
          ),
        ),
      ),
    );
  }

  static bool _isFeedbackDue(DuelState previous, DuelState current) {
    if (current is DuelFinished) return previous is! DuelFinished;
    return current is DuelRunning &&
        previous is DuelRunning &&
        current.answerCount != previous.answerCount;
  }

  static GameFeedback _feedbackOf(DuelState state) => switch (state) {
    DuelFinished() => GameFeedback.celebration,
    DuelRunning(isLastAnswerRight: true) => GameFeedback.rightAnswer,
    _ => GameFeedback.wrongAnswer,
  };
}

class _DuelBody extends StatelessWidget {
  const _DuelBody({
    required this.state,
    required this.avatarOf,
    required this.onPause,
    required this.onClose,
  });

  final DuelState state;
  final DuelAvatarBuilder avatarOf;
  final VoidCallback onPause;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final DuelBloc bloc = context.read<DuelBloc>();
    return switch (state) {
      DuelRunning(:final game) => SafeArea(
        child: DuelArena(
          game: game,
          avatarOf: avatarOf,
          onAnswer: (DuelSide side, Answer answer) =>
              bloc.add(PlayerAnswered(side: side, answer: answer)),
          onPause: onPause,
        ),
      ),
      final DuelChoosingPlayers choosing => SafeArea(
        child: DuelPlayerPicker(
          state: choosing,
          avatarOf: avatarOf,
          onPick: (DuelSide side, DuelPlayer player) =>
              bloc.add(DuelPlayerPicked(side: side, player: player)),
          onStart: (DuelLineup lineup) => bloc.add(DuelStarted(lineup: lineup)),
          onBack: onClose,
        ),
      ),
      DuelFinished(:final game, :final outcome) => SafeArea(
        child: DuelResultView(
          game: game,
          outcome: outcome,
          avatarOf: avatarOf,
          onReplay: () => bloc.add(const DuelRestarted()),
          onQuit: onClose,
        ),
      ),
      DuelFailure(:final errorCode) => SafeArea(
        child: _FailureView(
          message: errorCode.toChallengeMessage(context.l10n),
          onClose: onClose,
        ),
      ),
      DuelLoading() || DuelSaving() => const Center(
        child: CircularProgressIndicator(),
      ),
    };
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space24,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          DepthButton(label: context.l10n.commonBack, onPressed: onClose),
        ],
      ),
    );
  }
}

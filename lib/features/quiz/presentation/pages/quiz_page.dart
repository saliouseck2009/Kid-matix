import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quit_quiz_dialog.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_play_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_session_error_message.dart';

/// Full-screen quiz, without the tab bar.
class QuizPage extends StatelessWidget {
  /// Creates the page of [request].
  const QuizPage({
    required this.request,
    required this.useCases,
    required this.ticker,
    required this.domains,
    required this.onCompleted,
    required this.onLeft,
    super.key,
  });

  /// Quiz to play.
  final QuizRequest request;

  /// Use cases of the quiz.
  final QuizUseCases useCases;

  /// Source of the timer ticks.
  final Ticker ticker;

  /// Learning domains, to name units and facts.
  final DomainRegistry domains;

  /// Called with the saved session identifier after the last question.
  final ValueChanged<String> onCompleted;

  /// Called once the player left the quiz.
  final VoidCallback onLeft;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>(
      create: (_) =>
          QuizBloc(useCases: useCases, ticker: ticker)
            ..add(QuizStarted(request: request)),
      child: _QuizLifecycle(
        child: BlocConsumer<QuizBloc, QuizState>(
          listenWhen: (QuizState previous, QuizState current) =>
              current is QuizCompleted || current is QuizLeft,
          listener: (BuildContext context, QuizState state) => switch (state) {
            QuizCompleted(:final session) => onCompleted(session.id),
            _ => onLeft(),
          },
          builder: (BuildContext context, QuizState state) {
            final Widget scaffold = _QuizScaffold(
              state: state,
              labels: QuizLabels(domains: domains, l10n: context.l10n),
              onLeft: onLeft,
            );
            if (!request.isBossFight) return scaffold;
            return Theme(data: AppTheme.boss, child: scaffold);
          },
        ),
      ),
    );
  }
}

class _QuizScaffold extends StatelessWidget {
  const _QuizScaffold({
    required this.state,
    required this.labels,
    required this.onLeft,
  });

  final QuizState state;
  final QuizLabels labels;
  final VoidCallback onLeft;

  Future<void> _confirmQuit(BuildContext context) async {
    final QuizBloc bloc = context.read<QuizBloc>();
    if (await confirmQuitQuiz(context)) bloc.add(const QuizAbandoned());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _confirmQuit(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: switch (state) {
            QuizAsking() || QuizShowingFeedback() => QuizPlayView(
              state: state,
              labels: labels,
              onQuit: () => _confirmQuit(context),
            ),
            QuizFailure(:final errorCode) => _QuizFailureView(
              message: errorCode.toQuizMessage(context.l10n),
              onLeft: onLeft,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _QuizFailureView extends StatelessWidget {
  const _QuizFailureView({required this.message, required this.onLeft});

  final String message;
  final VoidCallback onLeft;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.space24,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            DepthButton(label: context.l10n.commonBack, onPressed: onLeft),
          ],
        ),
      ),
    );
  }
}

/// Pauses the quiz while the app is in the background.
class _QuizLifecycle extends StatefulWidget {
  const _QuizLifecycle({required this.child});

  final Widget child;

  @override
  State<_QuizLifecycle> createState() => _QuizLifecycleState();
}

class _QuizLifecycleState extends State<_QuizLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => context.read<QuizBloc>().add(const QuizPaused()),
      onShow: () => context.read<QuizBloc>().add(const QuizResumed()),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

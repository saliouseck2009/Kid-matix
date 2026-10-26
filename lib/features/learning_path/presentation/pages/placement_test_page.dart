import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_offer_view.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_question_view.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_quit_dialog.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_result_view.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';

/// The placement test of a player: the offer with « Passer », the typical
/// questions of each skill while the child succeeds, then the level found
/// (mockup 18, adapted).
///
/// [onDone] opens the path, whether the test was skipped, left midway or
/// finished. In a class assessment ([isAssessment]), the test cannot be
/// skipped, its end goes on with [onDone] (« Continuer », the word
/// check), and leaving it goes to [onLeave]: the assessment stays
/// pending.
class PlacementTestPage extends StatelessWidget {
  /// Creates the page.
  const PlacementTestPage({
    required this.profileId,
    required this.useCases,
    required this.clock,
    required this.slots,
    required this.onDone,
    this.isAssessment = false,
    this.onLeave,
    super.key,
  });

  /// Player of the test.
  final String profileId;

  /// Use cases of the test.
  final PlacementUseCases useCases;

  /// Measures the time taken by each answer.
  final Clock clock;

  /// Question card and keypad of the quiz.
  final PlacementSlots slots;

  /// Opens the path, or goes on with the class assessment.
  final VoidCallback onDone;

  /// Whether the test is part of a class assessment.
  final bool isAssessment;

  /// Leaves the test before its end; [onDone] when `null`.
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlacementBloc>(
      create: (_) =>
          PlacementBloc(profileId: profileId, useCases: useCases, clock: clock),
      child: _PlacementScaffold(page: this),
    );
  }
}

class _PlacementScaffold extends StatelessWidget {
  const _PlacementScaffold({required this.page});

  final PlacementTestPage page;

  VoidCallback get _leaveTo => page.onLeave ?? page.onDone;

  Future<void> _leave(BuildContext context) async {
    final PlacementState state = context.read<PlacementBloc>().state;
    if (state is PlacementFinished) {
      page.onDone();
      return;
    }
    if (state is PlacementAsking) {
      final bool isConfirmed = await confirmQuitPlacement(
        context,
        isAssessment: page.isAssessment,
      );
      if (!isConfirmed) return;
    }
    _leaveTo();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _leave(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<PlacementBloc, PlacementState>(
            builder: (BuildContext context, PlacementState state) {
              return switch (state) {
                PlacementOffered() => PlacementOfferView(
                  onStart: () => context.read<PlacementBloc>().add(
                    const PlacementStarted(),
                  ),
                  onSkip: page.isAssessment ? null : page.onDone,
                ),
                PlacementLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PlacementAsking() => PlacementQuestionView(
                  profileId: page.profileId,
                  state: state,
                  slots: page.slots,
                  onQuit: () => _leave(context),
                ),
                PlacementFinished() => PlacementResultView(
                  outcome: state.outcome,
                  isAssessment: page.isAssessment,
                  onSeePath: page.onDone,
                ),
                PlacementFailure(:final errorCode) => _PlacementError(
                  message: switch (errorCode) {
                    AppErrorCode.cache => context.l10n.errorStorage,
                    _ => context.l10n.errorUnknown,
                  },
                  onDone: _leaveTo,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _PlacementError extends StatelessWidget {
  const _PlacementError({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          DepthButton(label: context.l10n.placementSeePath, onPressed: onDone),
        ],
      ),
    );
  }
}

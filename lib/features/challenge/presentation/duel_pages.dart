import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_bloc.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_event.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/pages/duel_page.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';

/// Builds the duel on one phone for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class DuelPages {
  /// Creates the factory.
  const DuelPages({
    required this._useCases,
    required this._ticker,
    required this._feedback,
  });

  final DuelUseCases _useCases;
  final Ticker _ticker;
  final GameFeedbackService _feedback;

  /// The duel, with [activeProfileId] offered for the bottom half;
  /// [avatarOf] draws the profiles and [onClose] leaves.
  Widget buildDuelPage({
    required String? activeProfileId,
    required DuelAvatarBuilder avatarOf,
    required VoidCallback onClose,
  }) {
    return BlocProvider<DuelBloc>(
      create: (_) => DuelBloc(
        useCases: _useCases,
        ticker: _ticker,
        activeProfileId: activeProfileId,
      )..add(const DuelOpened()),
      child: DuelPage(
        avatarOf: avatarOf,
        feedback: _feedback,
        onClose: onClose,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_outcome.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/usecases/duel_answer_params.dart';
import 'package:kid_matix/features/challenge/domain/usecases/duel_elapse_params.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_event.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_state.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_use_cases.dart';

/// Drives a duel: the choice of the players, the race, then the winner
/// and the XP.
///
/// Every event waits for the previous one, so two taps at the same time
/// are judged one after the other, each on its own half. The ticks of
/// the injected [Ticker] shorten the 2-second block after a mistake.
final class DuelBloc extends Bloc<DuelEvent, DuelState> {
  /// Creates the Bloc; [activeProfileId] is offered for the bottom half.
  DuelBloc({
    required this._useCases,
    required this._ticker,
    this._activeProfileId,
  }) : super(const DuelLoading()) {
    on<DuelEvent>(_onEvent, transformer: _sequential);
  }

  /// Time between two ticks.
  static const Duration tickInterval = Duration(milliseconds: 100);

  final DuelUseCases _useCases;
  final Ticker _ticker;
  final String? _activeProfileId;
  List<PlayerIdentity> _players = const <PlayerIdentity>[];
  DuelLineup? _lineup;
  StreamSubscription<int>? _ticks;

  static Stream<DuelEvent> _sequential(
    Stream<DuelEvent> events,
    EventMapper<DuelEvent> mapper,
  ) {
    return events.asyncExpand(mapper);
  }

  Future<void> _onEvent(DuelEvent event, Emitter<DuelState> emit) async {
    switch (event) {
      case DuelOpened():
        await _open(emit);
      case DuelPlayerPicked(:final side, :final player):
        final DuelState current = state;
        if (current is DuelChoosingPlayers &&
            current.playerOf(side.opponent) != player) {
          emit(current.withPlayer(side, player));
        }
      case DuelStarted(:final lineup):
        await _start(lineup, emit);
      case PlayerAnswered():
        await _answer(event, emit);
      case DuelTicked():
        await _elapse(emit);
      case DuelRestarted():
        final DuelLineup? lineup = _lineup;
        if (lineup != null) await _start(lineup, emit);
      case DuelAbandoned():
        _stopTicks();
        emit(_choosing(_lineup));
    }
  }

  Future<void> _open(Emitter<DuelState> emit) async {
    emit(const DuelLoading());
    final DataState<List<PlayerIdentity>> players = await _useCases
        .getPlayers();
    switch (players) {
      case DataSuccess<List<PlayerIdentity>>(:final data):
        _players = data;
        emit(_choosing(null));
      case DataFailed<List<PlayerIdentity>>(:final exception):
        emit(DuelFailure(errorCode: exception.code));
    }
  }

  /// The choice of the players: [lineup] again, else the active player
  /// at the bottom, and the guest at the top when nobody else can play.
  DuelChoosingPlayers _choosing(DuelLineup? lineup) {
    if (lineup != null) {
      return DuelChoosingPlayers(
        players: _players,
        top: lineup.top,
        bottom: lineup.bottom,
      );
    }
    final PlayerIdentity? active = _players
        .where((PlayerIdentity player) => player.id == _activeProfileId)
        .firstOrNull;
    return DuelChoosingPlayers(
      players: _players,
      top: _players.length < 2 ? const GuestDuelPlayer() : null,
      bottom: active == null ? null : ProfileDuelPlayer(active),
    );
  }

  Future<void> _start(DuelLineup lineup, Emitter<DuelState> emit) async {
    _stopTicks();
    _lineup = lineup;
    emit(const DuelLoading());
    switch (await _useCases.start(params: lineup)) {
      case DataSuccess<DuelGameEntity>(:final data):
        emit(DuelRunning(lineup: lineup, game: data));
        _ticks = _ticker
            .tick(interval: tickInterval)
            .listen((_) => add(const DuelTicked()));
      case DataFailed<DuelGameEntity>(:final exception):
        emit(DuelFailure(errorCode: exception.code));
    }
  }

  Future<void> _answer(PlayerAnswered event, Emitter<DuelState> emit) async {
    final DuelState current = state;
    if (current is! DuelRunning) return;
    final DuelGameEntity game = await _useCases.answer(
      params: DuelAnswerParams(
        game: current.game,
        side: event.side,
        answer: event.answer,
      ),
    );
    if (game == current.game) return;
    emit(
      DuelRunning(
        lineup: current.lineup,
        game: game,
        answerCount: current.answerCount + 1,
        isLastAnswerRight:
            game.of(event.side).score > current.game.of(event.side).score,
      ),
    );
    if (game.isOver) await _finish(current.lineup, game, emit);
  }

  Future<void> _elapse(Emitter<DuelState> emit) async {
    final DuelState current = state;
    if (current is! DuelRunning || !current.game.hasBlockedContender) return;
    final DuelGameEntity game = await _useCases.elapse(
      params: DuelElapseParams(game: current.game, elapsed: tickInterval),
    );
    emit(
      DuelRunning(
        lineup: current.lineup,
        game: game,
        answerCount: current.answerCount,
        isLastAnswerRight: current.isLastAnswerRight,
      ),
    );
  }

  Future<void> _finish(
    DuelLineup lineup,
    DuelGameEntity game,
    Emitter<DuelState> emit,
  ) async {
    _stopTicks();
    emit(DuelSaving(lineup: lineup, game: game));
    final DuelOutcome outcome = await _useCases.finish(params: game);
    emit(DuelFinished(lineup: lineup, game: game, outcome: outcome));
  }

  /// Stops the ticks without waiting for the cancel, as the quiz does:
  /// waiting for it could hold the next events back.
  void _stopTicks() {
    unawaited(_ticks?.cancel());
    _ticks = null;
  }

  @override
  Future<void> close() {
    _stopTicks();
    return super.close();
  }
}

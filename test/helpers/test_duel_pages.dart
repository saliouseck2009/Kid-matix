import 'dart:async';

import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/services/player_directory_service.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/services/xp_award_service.dart';
import 'package:kid_matix/features/challenge/domain/usecases/answer_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/elapse_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/finish_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_duel_players_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/start_duel_use_case.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/duel_pages.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../features/challenge/helpers/challenge_fakes.dart';
import 'recording_game_feedback.dart';
import 'test_quiz_pages.dart';

/// Awa, a player of the phone.
const PlayerIdentity awa = PlayerIdentity(
  id: 'p-awa',
  nickname: 'Awa',
  avatarKey: 'avatar1',
  colorKey: 'violet',
);

/// Moussa, another player of the phone.
const PlayerIdentity moussa = PlayerIdentity(
  id: 'p-moussa',
  nickname: 'Moussa',
  avatarKey: 'avatar2',
  colorKey: 'green',
);

/// [PlayerDirectoryService] returning fixed players, or failing.
final class FixedPlayerDirectory implements PlayerDirectoryService {
  /// Creates the directory of [players]; `null` fails.
  const FixedPlayerDirectory([
    this.players = const <PlayerIdentity>[awa, moussa],
  ]);

  /// Players returned, or `null` to fail.
  final List<PlayerIdentity>? players;

  @override
  Future<DataState<List<PlayerIdentity>>> readPlayers() async {
    final List<PlayerIdentity>? list = players;
    if (list == null) {
      return const DataFailed<List<PlayerIdentity>>(
        CacheException(message: 'down'),
      );
    }
    return DataSuccess<List<PlayerIdentity>>(list);
  }
}

/// [XpAwardService] keeping the XP it was given, or failing.
final class RecordingXpAwards implements XpAwardService {
  /// Creates the service; [isFailing] refuses every award.
  RecordingXpAwards({this.isFailing = false});

  /// Whether every award fails.
  final bool isFailing;

  /// XP given, per profile.
  final Map<String, int> awarded = <String, int>{};

  @override
  Future<DataState<void>> awardXp({
    required String profileId,
    required int xp,
    required String sourceKey,
  }) async {
    if (isFailing) {
      return const DataFailed<void>(CacheException(message: 'down'));
    }
    awarded[profileId] = (awarded[profileId] ?? 0) + xp;
    return const DataSuccess<void>(null);
  }
}

/// [Ticker] whose ticks the test sends by hand.
final class ManualTicker implements Ticker {
  /// Ticks to send.
  final StreamController<int> controller = StreamController<int>.broadcast();

  @override
  Stream<int> tick({required Duration interval}) => controller.stream;
}

/// Use cases of the duel over the multiplication domain and doubles.
DuelUseCases buildTestDuelUseCases({
  PlayerDirectoryService players = const FixedPlayerDirectory(),
  OpenUnitsService openUnits = const FixedOpenUnits(),
  XpAwardService? xpAwards,
  RandomSource? random,
}) {
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain());
  final RandomSource draw = random ?? DartRandomSource(seed: 7);
  return DuelUseCases(
    getPlayers: GetDuelPlayersUseCase(players: players),
    start: StartDuelUseCase(
      openUnits: openUnits,
      domains: domains,
      random: draw,
    ),
    answer: AnswerDuelUseCase(domains: domains, random: draw),
    elapse: ElapseDuelUseCase(domains: domains, random: draw),
    finish: FinishDuelUseCase(xpAwards: xpAwards ?? RecordingXpAwards()),
  );
}

/// Duel pages over doubles; the ticker never ticks unless given.
DuelPages buildTestDuelPages({
  DuelUseCases? useCases,
  Ticker ticker = const SilentTicker(),
  RecordingGameFeedback? feedback,
}) {
  return DuelPages(
    useCases: useCases ?? buildTestDuelUseCases(),
    ticker: ticker,
    feedback: feedback ?? RecordingGameFeedback(),
  );
}

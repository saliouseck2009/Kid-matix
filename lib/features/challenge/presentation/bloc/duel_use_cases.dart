import 'package:kid_matix/features/challenge/domain/usecases/answer_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/elapse_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/finish_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_duel_players_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/start_duel_use_case.dart';

/// The use cases the duel Bloc calls.
final class DuelUseCases {
  /// Groups the use cases.
  const DuelUseCases({
    required this.getPlayers,
    required this.start,
    required this.answer,
    required this.elapse,
    required this.finish,
  });

  /// The players of the phone.
  final GetDuelPlayersUseCase getPlayers;

  /// Opens a duel.
  final StartDuelUseCase start;

  /// Judges an answer.
  final AnswerDuelUseCase answer;

  /// Lets time pass.
  final ElapseDuelUseCase elapse;

  /// Gives the XP of a won duel.
  final FinishDuelUseCase finish;
}

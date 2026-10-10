import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenges_state.dart';

/// Reads the challenges of a player and their records, and follows the
/// new records.
final class ChallengesCubit extends Cubit<ChallengesState> {
  /// Creates the Cubit of the player [profileId].
  ChallengesCubit({required this._profileId, required this._useCases})
    : super(const ChallengesLoading());

  final String _profileId;
  final ChallengeUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the challenges and follows the records.
  Future<void> load() async {
    _changes ??= _useCases.watchRecordChanges().listen(
      (_) => unawaited(_reload()),
    );
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<TimeAttackSource> timeAttack = await _useCases
        .getTimeAttack(params: _profileId);
    final DataState<Map<QuizMode, RecordEntity>> records = await _useCases
        .getRecords(params: _profileId);
    if (isClosed) return;
    emit(switch ((timeAttack, records)) {
      (
        DataSuccess<TimeAttackSource>(data: final TimeAttackSource source),
        DataSuccess<Map<QuizMode, RecordEntity>>(
          data: final Map<QuizMode, RecordEntity> best,
        ),
      ) =>
        ChallengesLoaded(timeAttack: source, records: best),
      (DataFailed<TimeAttackSource>(:final exception), _) ||
      (
        _,
        DataFailed<Map<QuizMode, RecordEntity>>(:final exception),
      ) => ChallengesFailure(errorCode: exception.code),
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}

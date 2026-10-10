import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/training_state.dart';

/// Holds the free training a child is choosing: tables, question count
/// and timer.
final class TrainingCubit extends Cubit<TrainingState> {
  /// Creates the Cubit of the player [profileId].
  TrainingCubit({required this._profileId, required this._useCases})
    : super(const TrainingLoading());

  final String _profileId;
  final ChallengeUseCases _useCases;

  /// Reads the choice to offer: the last one of the player.
  Future<void> load() async {
    emit(const TrainingLoading());
    final DataState<TrainingSource> read = await _useCases.getTrainingChoice(
      params: _profileId,
    );
    emit(switch (read) {
      DataSuccess<TrainingSource>(:final data) => TrainingReady(choice: data),
      DataFailed<TrainingSource>(:final exception) => TrainingFailure(
        errorCode: exception.code,
      ),
    });
  }

  /// Chooses the table [unitKey], or leaves it out when it was chosen.
  void toggleUnit(String unitKey) {
    _update((TrainingSource choice) {
      final List<String> units = List<String>.of(choice.unitKeys);
      if (!units.remove(unitKey)) units.add(unitKey);
      return choice.copyWith(unitKeys: units);
    });
  }

  /// Chooses to ask [count] questions.
  void pickQuestionCount(int count) {
    _update((TrainingSource choice) => choice.copyWith(questionCount: count));
  }

  /// Chooses to play with or without a timer.
  void setTimer({required bool hasTimer}) {
    _update((TrainingSource choice) => choice.copyWith(hasTimer: hasTimer));
  }

  /// Keeps the choice for next time and returns it, or `null` while no
  /// table is chosen.
  Future<TrainingSource?> launch() async {
    final TrainingState current = state;
    if (current is! TrainingReady || !current.canLaunch) return null;
    await _useCases.saveTrainingChoice(
      params: (profileId: _profileId, choice: current.choice),
    );
    return current.choice;
  }

  void _update(TrainingSource Function(TrainingSource choice) change) {
    final TrainingState current = state;
    if (current is TrainingReady) {
      emit(TrainingReady(choice: change(current.choice)));
    }
  }
}

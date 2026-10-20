import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';

/// Drives the placement test of a player: the offer, then the typical
/// questions of each skill on the keypad, climbing while the child has the
/// skill, then the level found in each domain.
///
/// Each answer is recorded as soon as it is given and opens its units, so
/// a test left midway keeps the units already found; only a finished test
/// is kept with its date. No timer and no feedback per question: the result
/// screen tells what was found.
final class PlacementBloc extends Bloc<PlacementEvent, PlacementState> {
  /// Creates the Bloc for the player [_profileId]; [clock] measures the
  /// time taken by each answer.
  PlacementBloc({
    required this._profileId,
    required this._useCases,
    required this._clock,
  }) : super(const PlacementOffered()) {
    on<PlacementStarted>(_onStarted);
    on<PlacementDigitTyped>(_onDigitTyped);
    on<PlacementDigitErased>(_onDigitErased);
    on<PlacementAnswerValidated>(_onAnswerValidated);
    on<PlacementAnswerUnknown>(_onAnswerUnknown);
  }

  final String _profileId;
  final PlacementUseCases _useCases;
  final Clock _clock;

  Future<void> _onStarted(
    PlacementStarted event,
    Emitter<PlacementState> emit,
  ) async {
    if (state is! PlacementOffered) return;
    emit(const PlacementLoading());
    emit(await _ask(PlacementJourney.start()));
  }

  void _onDigitTyped(
    PlacementDigitTyped event,
    Emitter<PlacementState> emit,
  ) {
    final PlacementState current = state;
    if (current is! PlacementAsking || current.isSubmitting) return;
    emit(current.withDigit(event.digit));
  }

  void _onDigitErased(
    PlacementDigitErased event,
    Emitter<PlacementState> emit,
  ) {
    final PlacementState current = state;
    if (current is! PlacementAsking || current.isSubmitting) return;
    emit(current.withoutLastDigit());
  }

  Future<void> _onAnswerValidated(
    PlacementAnswerValidated event,
    Emitter<PlacementState> emit,
  ) async {
    final PlacementState current = state;
    if (current is! PlacementAsking || current.typedDigits.isEmpty) return;
    await _submit(current, NumberAnswer(int.parse(current.typedDigits)), emit);
  }

  Future<void> _onAnswerUnknown(
    PlacementAnswerUnknown event,
    Emitter<PlacementState> emit,
  ) async {
    final PlacementState current = state;
    if (current is! PlacementAsking) return;
    await _submit(current, null, emit);
  }

  Future<void> _submit(
    PlacementAsking current,
    Answer? answer,
    Emitter<PlacementState> emit,
  ) async {
    if (current.isSubmitting) return;
    emit(current.copyWith(isSubmitting: true));
    final DataState<bool> recorded = await _useCases.answerQuestion(
      params: PlacementAnswerParams(
        profileId: _profileId,
        domainId: current.domainId,
        question: current.question,
        answer: answer,
        answerTime: _clock.now().difference(current.askedAt),
        unitKeysToOpen: current.journey.unitKeysToOpen,
      ),
    );
    switch (recorded) {
      case DataSuccess<bool>(:final data):
        final PlacementJourney next = current.journey.answered(
          isCorrect: data,
        );
        emit(next.isOver ? await _finish(next) : await _ask(next));
      case DataFailed<bool>(:final exception):
        emit(PlacementFailure(errorCode: exception.code));
    }
  }

  /// Builds the question [journey] asks next.
  Future<PlacementState> _ask(PlacementJourney journey) async {
    final DataState<Question> question = await _useCases.buildQuestion(
      params: PlacementProbeParams(
        domainId: journey.skill!.domainId,
        unitKey: journey.probeUnitKey!,
      ),
    );
    return switch (question) {
      DataSuccess<Question>(:final data) => PlacementAsking(
        journey: journey,
        question: data,
        askedAt: _clock.now(),
      ),
      DataFailed<Question>(:final exception) => PlacementFailure(
        errorCode: exception.code,
      ),
    };
  }

  /// Keeps the result of the finished [journey].
  Future<PlacementState> _finish(PlacementJourney journey) async {
    final DataState<void> saved = await _useCases.saveResult(
      params: SavePlacementResultParams(
        profileId: _profileId,
        outcome: journey.outcome,
      ),
    );
    return switch (saved) {
      DataSuccess<void>() => PlacementFinished(outcome: journey.outcome),
      DataFailed<void>(:final exception) => PlacementFailure(
        errorCode: exception.code,
      ),
    };
  }
}

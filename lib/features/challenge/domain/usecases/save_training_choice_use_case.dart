import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/repositories/training_choice_repository.dart';

/// What [SaveTrainingChoiceUseCase] keeps.
typedef TrainingChoiceParams = ({String profileId, TrainingSource choice});

/// Keeps the free training a player launches, to offer it again.
class SaveTrainingChoiceUseCase
    implements UseCase<DataState<void>, TrainingChoiceParams> {
  /// Creates the use case.
  const SaveTrainingChoiceUseCase({required this._repository});

  final TrainingChoiceRepository _repository;

  @override
  Future<DataState<void>> call({required TrainingChoiceParams params}) {
    return _repository.saveChoice(
      profileId: params.profileId,
      choice: params.choice,
    );
  }
}

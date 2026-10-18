import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';

/// Keeps the domain a player chose, so the map and the Profile show it
/// again, now and at the next launch.
class SelectDomainUseCase
    implements UseCase<DataState<void>, LearningPathParams> {
  /// Creates the use case over [repository].
  const SelectDomainUseCase({required this._repository});

  final PathDomainRepository _repository;

  @override
  Future<DataState<void>> call({required LearningPathParams params}) {
    return _repository.saveDomain(
      profileId: params.profileId,
      domainId: params.domainId,
    );
  }
}

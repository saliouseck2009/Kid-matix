import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Lists every player of the device, oldest first.
final class GetProfilesUseCase
    implements NoParamUseCase<DataState<List<ProfileEntity>>> {
  /// Creates the use case over [repository].
  const GetProfilesUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<List<ProfileEntity>>> call() => _repository.getProfiles();
}

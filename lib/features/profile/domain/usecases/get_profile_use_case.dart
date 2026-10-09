import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Reads one player from their identifier.
///
/// Fails with a `NotFoundException` when the profile does not exist.
class GetProfileUseCase implements UseCase<DataState<ProfileEntity>, String> {
  /// Creates the use case over [repository].
  const GetProfileUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<ProfileEntity>> call({required String params}) {
    return _repository.getProfile(profileId: params);
  }
}

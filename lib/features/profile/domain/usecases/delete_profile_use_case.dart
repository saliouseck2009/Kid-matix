import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Deletes a player and all of their data.
///
/// Takes the identifier of the profile to delete. The screen asks the child
/// to type the nickname again before calling it.
class DeleteProfileUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case over [repository].
  const DeleteProfileUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<void>> call({required String params}) {
    return _repository.deleteProfile(profileId: params);
  }
}

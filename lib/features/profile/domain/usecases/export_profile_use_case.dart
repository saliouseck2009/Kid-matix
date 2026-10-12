import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_backup_repository.dart';

/// Writes the backup of a player to a file and opens the share sheet.
///
/// Takes the identifier of the player; resolves to whether the file was
/// shared. The screen asks an adult first.
class ExportProfileUseCase implements UseCase<DataState<bool>, String> {
  /// Creates the use case over [repository].
  const ExportProfileUseCase({required this._repository});

  final ProfileBackupRepository _repository;

  @override
  Future<DataState<bool>> call({required String params}) {
    return _repository.exportProfile(profileId: params);
  }
}

import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Lets another child play: nobody is active until a player is chosen.
///
/// No data is lost; the router goes back to "Qui joue ?".
class ClearActiveProfileUseCase implements NoParamUseCase<DataState<void>> {
  /// Creates the use case over [repository].
  const ClearActiveProfileUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<void>> call() => _repository.clearActiveProfileId();
}

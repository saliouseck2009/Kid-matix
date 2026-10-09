import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_session_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Reads how many profiles exist and which one is active.
class GetProfileSessionUseCase
    implements NoParamUseCase<DataState<ProfileSessionEntity>> {
  /// Creates the use case over [repository].
  const GetProfileSessionUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<ProfileSessionEntity>> call() async {
    final DataState<int> countState = await _repository.countProfiles();
    if (countState case DataFailed<int>(:final exception)) {
      return DataFailed<ProfileSessionEntity>(exception);
    }
    final DataState<String?> activeState = await _repository
        .getActiveProfileId();
    return switch (activeState) {
      DataFailed<String?>(:final exception) => DataFailed<ProfileSessionEntity>(
        exception,
      ),
      DataSuccess<String?>(:final String? data) =>
        DataSuccess<ProfileSessionEntity>(
          ProfileSessionEntity(
            profileCount: (countState as DataSuccess<int>).data,
            activeProfileId: data,
          ),
        ),
    };
  }
}

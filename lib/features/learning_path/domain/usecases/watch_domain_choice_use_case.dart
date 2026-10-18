import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';

/// Emits an event each time the player [profileId] chooses another
/// domain, on the map or in the Profile.
class WatchDomainChoiceUseCase {
  /// Creates the use case over [repository].
  const WatchDomainChoiceUseCase({required this._repository});

  final PathDomainRepository _repository;

  /// Returns the stream of the changes of [profileId].
  Stream<void> call({required String profileId}) {
    return _repository.watchChanges().where(
      (String changed) => changed == profileId,
    );
  }
}

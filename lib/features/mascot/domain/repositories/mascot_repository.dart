import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';

/// The mascot choices of each player.
abstract interface class MascotRepository {
  /// Returns the record of [profileId], the initial one before any choice.
  Future<DataState<MascotRecord>> getMascot({required String profileId});

  /// Creates or replaces the record of [profileId].
  Future<DataState<void>> saveMascot({
    required String profileId,
    required MascotRecord mascot,
  });

  /// Emits an event each time a mascot record changes.
  Stream<void> watchChanges();
}

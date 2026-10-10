import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_accessory.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';

/// Changes the choices of the child: the name, the accessories, the stage
/// celebrated.
class UpdateMascotUseCases {
  /// Creates the use cases.
  const UpdateMascotUseCases({
    required this._repository,
    this._rules = const MascotRules(),
  });

  final MascotRepository _repository;
  final MascotRules _rules;

  /// Names the mascot of [profileId]; an empty name gives back the default.
  Future<DataState<void>> rename({
    required String profileId,
    required String name,
  }) {
    return _update(
      profileId,
      (MascotRecord mascot) => MascotRecord(
        name: _rules.cleanName(name),
        worn: mascot.worn,
        celebratedStage: mascot.celebratedStage,
      ),
    );
  }

  /// Puts [accessory] on, replacing the one of its slot, or takes it off
  /// when it is already worn.
  Future<DataState<void>> toggleAccessory({
    required String profileId,
    required MascotAccessory accessory,
  }) {
    return _update(profileId, (MascotRecord mascot) {
      final bool isWorn = mascot.worn.contains(accessory);
      return MascotRecord(
        name: mascot.name,
        worn: <MascotAccessory>[
          for (final MascotAccessory other in mascot.worn)
            if (other.slot != accessory.slot) other,
          if (!isWorn) accessory,
        ],
        celebratedStage: mascot.celebratedStage,
      );
    });
  }

  /// Remembers that the growth to [stage] was celebrated.
  Future<DataState<void>> markCelebrated({
    required String profileId,
    required int stage,
  }) {
    return _update(
      profileId,
      (MascotRecord mascot) => MascotRecord(
        name: mascot.name,
        worn: mascot.worn,
        celebratedStage: stage > mascot.celebratedStage
            ? stage
            : mascot.celebratedStage,
      ),
    );
  }

  Future<DataState<void>> _update(
    String profileId,
    MascotRecord Function(MascotRecord mascot) change,
  ) async {
    final DataState<MascotRecord> stored = await _repository.getMascot(
      profileId: profileId,
    );
    return switch (stored) {
      DataSuccess<MascotRecord>(:final data) => _repository.saveMascot(
        profileId: profileId,
        mascot: change(data),
      ),
      DataFailed<MascotRecord>(:final exception) => DataFailed<void>(exception),
    };
  }
}

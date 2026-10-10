import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:meta/meta.dart';

/// How the mascot of the active player looks: its stage and what it
/// wears.
@immutable
final class MascotLook {
  /// Creates the look.
  MascotLook({required this.stage, required Set<MascotAccessory> accessories})
    : accessories = Set<MascotAccessory>.unmodifiable(accessories);

  /// Look of a new mascot: stage 1, nothing worn.
  const MascotLook.initial()
    : stage = 1,
      accessories = const <MascotAccessory>{};

  /// Stage, from 1 to 5.
  final int stage;

  /// Accessories worn.
  final Set<MascotAccessory> accessories;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MascotLook &&
            other.stage == stage &&
            other.accessories.length == accessories.length &&
            other.accessories.containsAll(accessories);
  }

  @override
  int get hashCode => Object.hash(stage, Object.hashAllUnordered(accessories));
}

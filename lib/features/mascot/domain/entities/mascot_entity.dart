import 'package:kid_matix/features/mascot/domain/entities/accessory_slot.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_accessory.dart';
import 'package:meta/meta.dart';

/// The mascot of a player: its name, its stage and its accessories.
@immutable
final class MascotEntity {
  /// Creates the mascot.
  MascotEntity({
    required this.name,
    required this.stage,
    required this.nextStageLevel,
    required Set<MascotAccessory> unlocked,
    required Map<AccessorySlot, MascotAccessory> worn,
    this.isNewStage = false,
  }) : unlocked = Set<MascotAccessory>.unmodifiable(unlocked),
       worn = Map<AccessorySlot, MascotAccessory>.unmodifiable(worn);

  /// Name the child gave it.
  final String name;

  /// Stage, from 1 to 5.
  final int stage;

  /// Level of the next stage, or `null` at the last one.
  final int? nextStageLevel;

  /// Accessories the player has earned.
  final Set<MascotAccessory> unlocked;

  /// Accessory worn in each slot, among [unlocked].
  final Map<AccessorySlot, MascotAccessory> worn;

  /// Whether the mascot reached [stage] since its last celebration.
  final bool isNewStage;
}

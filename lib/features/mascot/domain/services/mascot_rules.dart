import 'package:kid_matix/core/entities/accessory_slot.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';

/// The rules of the mascot: its stages and its accessories.
///
/// The mascot grows with the player's level and never goes back. Each
/// crown unlocks the next accessory of the catalog, some badges one each.
final class MascotRules {
  /// Creates the rules.
  const MascotRules();

  /// Level at which each stage starts: index 0 is stage 1.
  static const List<int> stageLevels = <int>[1, 5, 10, 20, 30];

  /// Last stage.
  static int get lastStage => stageLevels.length;

  /// Name of a mascot the child has not named.
  static const String defaultName = 'Lim';

  /// Longest name of the mascot.
  static const int maxNameLength = 12;

  /// Stage of a player at [level].
  int stageOf(int level) {
    int stage = 1;
    for (int index = 1; index < stageLevels.length; index++) {
      if (level >= stageLevels[index]) stage = index + 1;
    }
    return stage;
  }

  /// Level of the stage after [stage], or `null` at the last one.
  int? nextStageLevel(int stage) {
    return stage < lastStage ? stageLevels[stage] : null;
  }

  /// Accessories earned with [crowns] crowns and the badges [badgeKeys].
  Set<MascotAccessory> unlockedBy({
    required int crowns,
    required Set<String> badgeKeys,
  }) {
    return <MascotAccessory>{
      for (final MascotAccessory accessory in MascotAccessory.values)
        if ((accessory.crownRank ?? crowns + 1) <= crowns ||
            badgeKeys.contains(accessory.badgeKey))
          accessory,
    };
  }

  /// The accessories of [wearing] that are earned, one per slot.
  Map<AccessorySlot, MascotAccessory> wornAmong({
    required Iterable<MascotAccessory> wearing,
    required Set<MascotAccessory> unlocked,
  }) {
    return <AccessorySlot, MascotAccessory>{
      for (final MascotAccessory accessory in wearing)
        if (unlocked.contains(accessory)) accessory.slot: accessory,
    };
  }

  /// A clean name: trimmed, at most [maxNameLength] characters, the
  /// default one when empty.
  String cleanName(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return defaultName;
    return trimmed.length <= maxNameLength
        ? trimmed
        : trimmed.substring(0, maxNameLength);
  }
}

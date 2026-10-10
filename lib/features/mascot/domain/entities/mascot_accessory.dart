import 'package:kid_matix/features/mascot/domain/entities/accessory_slot.dart';

/// The accessories of the mascot: one per crown, in the order the crowns
/// are won, and three earned with badges.
///
/// Stored by [name]: never rename a value once released.
enum MascotAccessory {
  /// First crown.
  cap(slot: AccessorySlot.head, crownRank: 1),

  /// Second crown.
  roundGlasses(slot: AccessorySlot.eyes, crownRank: 2),

  /// Third crown.
  cape(slot: AccessorySlot.back, crownRank: 3),

  /// Fourth crown.
  bowTie(slot: AccessorySlot.neck, crownRank: 4),

  /// Fifth crown.
  scarf(slot: AccessorySlot.neck, crownRank: 5),

  /// Sixth crown.
  wizardHat(slot: AccessorySlot.head, crownRank: 6),

  /// Seventh crown.
  sunglasses(slot: AccessorySlot.eyes, crownRank: 7),

  /// Eighth crown.
  backpack(slot: AccessorySlot.back, crownRank: 8),

  /// Ninth crown.
  headphones(slot: AccessorySlot.head, crownRank: 9),

  /// Tenth crown.
  medal(slot: AccessorySlot.neck, crownRank: 10),

  /// Eleventh crown.
  wings(slot: AccessorySlot.back, crownRank: 11),

  /// Twelfth crown.
  kingCrown(slot: AccessorySlot.head, crownRank: 12),

  /// The Régulier badge.
  partyHat(slot: AccessorySlot.head, badgeKey: 'regular'),

  /// The Éclair badge.
  lightningGoggles(slot: AccessorySlot.eyes, badgeKey: 'lightning'),

  /// The Les 120 badge.
  goldenCape(slot: AccessorySlot.back, badgeKey: 'allFacts');

  const MascotAccessory({required this.slot, this.crownRank, this.badgeKey});

  /// Where the mascot wears it.
  final AccessorySlot slot;

  /// Number of crowns that unlocks it, or `null`.
  final int? crownRank;

  /// Key of the badge that unlocks it, or `null`.
  final String? badgeKey;
}

import 'package:kid_matix/core/entities/accessory_slot.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the accessories and of their slots, and how to unlock them.
final class MascotLabels {
  /// Creates the labels.
  const MascotLabels({required this.l10n});

  /// Localized strings.
  final AppLocalizations l10n;

  /// Name of the slot, such as "Tête".
  String slotName(AccessorySlot slot) {
    return switch (slot) {
      AccessorySlot.head => l10n.mascotSlotHead,
      AccessorySlot.eyes => l10n.mascotSlotEyes,
      AccessorySlot.neck => l10n.mascotSlotNeck,
      AccessorySlot.back => l10n.mascotSlotBack,
    };
  }

  /// Name of the accessory, such as "Casquette".
  String accessoryName(MascotAccessory accessory) {
    return switch (accessory) {
      MascotAccessory.cap => l10n.mascotAccessoryCap,
      MascotAccessory.roundGlasses => l10n.mascotAccessoryRoundGlasses,
      MascotAccessory.cape => l10n.mascotAccessoryCape,
      MascotAccessory.bowTie => l10n.mascotAccessoryBowTie,
      MascotAccessory.scarf => l10n.mascotAccessoryScarf,
      MascotAccessory.wizardHat => l10n.mascotAccessoryWizardHat,
      MascotAccessory.sunglasses => l10n.mascotAccessorySunglasses,
      MascotAccessory.backpack => l10n.mascotAccessoryBackpack,
      MascotAccessory.headphones => l10n.mascotAccessoryHeadphones,
      MascotAccessory.medal => l10n.mascotAccessoryMedal,
      MascotAccessory.wings => l10n.mascotAccessoryWings,
      MascotAccessory.kingCrown => l10n.mascotAccessoryKingCrown,
      MascotAccessory.partyHat => l10n.mascotAccessoryPartyHat,
      MascotAccessory.lightningGoggles => l10n.mascotAccessoryLightningGoggles,
      MascotAccessory.goldenCape => l10n.mascotAccessoryGoldenCape,
    };
  }

  /// How to unlock the accessory, such as "À la 3e couronne".
  String unlockHint(MascotAccessory accessory) {
    final int? rank = accessory.crownRank;
    if (rank != null) return l10n.mascotUnlockCrown(rank);
    return switch (accessory) {
      MascotAccessory.partyHat => l10n.mascotUnlockRegular,
      MascotAccessory.lightningGoggles => l10n.mascotUnlockLightning,
      _ => l10n.mascotUnlockAllFacts,
    };
  }
}

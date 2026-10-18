import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Color and name of each mastery status in the grid and its legend.
extension MasteryStatusStyle on MasteryStatus {
  /// Color of a cell of this status, in the colors of the player's
  /// [palette]: the violets follow the theme applied in the shop.
  Color colorIn(AppPalette palette) => switch (this) {
    MasteryStatus.notSeen => palette.lockedFace,
    MasteryStatus.toReview => AppColors.coral,
    MasteryStatus.inProgress => AppColors.yellow,
    MasteryStatus.acquired => palette.strongBorder,
    MasteryStatus.mastered => palette.primaryText,
  };

  /// Name of this status, such as "Maîtrisé".
  String nameIn(AppLocalizations l10n) => switch (this) {
    MasteryStatus.notSeen => l10n.masteryStatusNotSeen,
    MasteryStatus.toReview => l10n.masteryStatusToReview,
    MasteryStatus.inProgress => l10n.masteryStatusInProgress,
    MasteryStatus.acquired => l10n.masteryStatusAcquired,
    MasteryStatus.mastered => l10n.masteryStatusMastered,
  };
}

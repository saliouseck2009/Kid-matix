import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Color and name of each mastery status in the grid and its legend.
extension MasteryStatusStyle on MasteryStatus {
  /// Color of a cell of this status.
  Color get color => switch (this) {
    MasteryStatus.notSeen => AppColors.lockedFace,
    MasteryStatus.toReview => AppColors.coral,
    MasteryStatus.inProgress => AppColors.yellow,
    MasteryStatus.acquired => AppColors.violetStrongBorder,
    MasteryStatus.mastered => AppColors.violetText,
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

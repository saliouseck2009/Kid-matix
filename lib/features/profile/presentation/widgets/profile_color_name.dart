import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Localized name of a profile color, read by screen readers.
extension ProfileColorName on ProfileColor {
  /// Returns the name of this color.
  String toName(AppLocalizations l10n) {
    return switch (this) {
      ProfileColor.violet => l10n.profileColorViolet,
      ProfileColor.green => l10n.profileColorGreen,
      ProfileColor.yellow => l10n.profileColorYellow,
      ProfileColor.red => l10n.profileColorRed,
      ProfileColor.blue => l10n.profileColorBlue,
      ProfileColor.pink => l10n.profileColorPink,
    };
  }
}

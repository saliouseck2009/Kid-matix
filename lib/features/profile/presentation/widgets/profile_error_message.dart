import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Turns a failure of the profile screens into text for a child.
extension ProfileErrorMessage on AppErrorCode {
  /// Returns the localized message of this code.
  String toProfileMessage(AppLocalizations l10n) {
    return switch (this) {
      AppErrorCode.cache => l10n.errorStorage,
      AppErrorCode.notFound => l10n.errorNotFound,
      AppErrorCode.conflict => l10n.nicknameTaken,
      AppErrorCode.limitReached => l10n.profileLimitReached(
        ProfileLimits.maxProfiles,
      ),
      AppErrorCode.validation || AppErrorCode.unknown => l10n.errorUnknown,
    };
  }
}

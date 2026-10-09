import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Turns a broken nickname rule into text for a child.
extension NicknameErrorMessage on NicknameError {
  /// Returns the localized message of this error.
  String toMessage(AppLocalizations l10n) {
    return switch (this) {
      NicknameError.tooShort => l10n.nicknameTooShort(NicknameRules.minLength),
      NicknameError.tooLong => l10n.nicknameTooLong(NicknameRules.maxLength),
      NicknameError.invalidCharacters => l10n.nicknameInvalidCharacters,
    };
  }
}

import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Turns a failure of the quiz screens into text for a child.
extension QuizSessionErrorMessage on AppErrorCode {
  /// Returns the localized message of this code.
  String toQuizMessage(AppLocalizations l10n) {
    return switch (this) {
      AppErrorCode.cache => l10n.errorStorage,
      AppErrorCode.notFound ||
      AppErrorCode.validation ||
      AppErrorCode.conflict ||
      AppErrorCode.limitReached ||
      AppErrorCode.unknown => l10n.errorUnknown,
    };
  }
}

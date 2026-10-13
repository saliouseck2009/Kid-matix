import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:meta/meta.dart';

/// The language of the interface, above the whole app.
@immutable
final class LanguageState {
  /// Creates the state.
  const LanguageState({
    required this.language,
    this.isSaving = false,
    this.errorCode,
  });

  /// Language chosen; the app shows it at once.
  final AppLanguage language;

  /// Whether the choice is being kept.
  final bool isSaving;

  /// Why the last choice could not be kept, or `null`.
  final AppErrorCode? errorCode;
}

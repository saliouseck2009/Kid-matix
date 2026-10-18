import 'package:meta/meta.dart';

/// A voice of the phone chosen to read in one language.
@immutable
final class OfflineVoice {
  /// Creates the choice of the voice [name] of [locale]; iOS picks its
  /// voice from the locale alone, so it has no [name].
  const OfflineVoice({required this.locale, this.name});

  /// Locale of the voice, such as `fr-FR`.
  final String locale;

  /// Name of the voice in the engine, or `null` when only the locale
  /// counts.
  final String? name;
}

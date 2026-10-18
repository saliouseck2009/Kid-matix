import 'package:kid_matix/core/utils/english_number_words.dart';
import 'package:kid_matix/core/utils/french_number_words.dart';
import 'package:kid_matix/core/utils/spanish_number_words.dart';

/// Writes a whole number in the words of one language of the app, for
/// the parental gate.
abstract final class NumberWords {
  /// Largest number spelled, in every language.
  static const int maxNumber = FrenchNumberWords.maxNumber;

  /// Returns [number], from 0 to [maxNumber], in words of the language
  /// [languageCode]; French words for a language the app does not speak.
  static String spell(int number, {required String languageCode}) {
    return switch (languageCode) {
      'en' => EnglishNumberWords.spell(number),
      'es' => SpanishNumberWords.spell(number),
      _ => FrenchNumberWords.spell(number),
    };
  }
}

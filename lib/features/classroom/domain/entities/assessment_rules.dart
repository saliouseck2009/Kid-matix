import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';

/// Rules of the class assessments (lot F31).
abstract final class AssessmentRules {
  /// Most characters of the label of a period.
  static const int maxLabelLength = 30;

  /// Words of each family of the math words in the word check: the first
  /// ones of the family, so every assessment asks the same words and two
  /// periods compare.
  static const int wordsPerFamily = 2;

  static const String _sourcePrefix = 'assessment:';

  /// Returns [label] without stray spaces, or `null` when it is empty or
  /// longer than [maxLabelLength].
  static String? cleanLabel(String label) {
    final String cleaned = label.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty || cleaned.runes.length > maxLabelLength) return null;
    return cleaned;
  }

  /// The key two labels of one period share: case, accents and spaces
  /// left out, so « Début d'année » on one tablet and « debut d'annee »
  /// on another are one period.
  static String periodKeyOf(String label) {
    const String accented = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿœæ';
    const String plain = 'aaaaaceeeeiiiinooooouuuuyyoa';
    final StringBuffer key = StringBuffer();
    for (final int rune in label.trim().toLowerCase().runes) {
      final String character = String.fromCharCode(rune);
      final int index = accented.indexOf(character);
      if (character.trim().isEmpty) continue;
      key.write(index < 0 ? character : plain[index]);
    }
    return key.toString();
  }

  /// The source key of the word check of [assessmentId], stored with its
  /// quiz session.
  static String sourceKeyOf(String assessmentId) =>
      '$_sourcePrefix$assessmentId';

  /// The assessment of the word check played for [sourceKey], or `null`
  /// for another quiz.
  static String? assessmentIdOf(String? sourceKey) {
    if (sourceKey == null || !sourceKey.startsWith(_sourcePrefix)) {
      return null;
    }
    final String id = sourceKey.substring(_sourcePrefix.length);
    return id.isEmpty ? null : id;
  }

  /// The words of the word check: the first [wordsPerFamily] of each
  /// family of [mathWords], in the order of the families.
  static List<String> wordCheckItemKeys(LearningDomain mathWords) {
    return <String>[
      for (final LearningUnit unit in mathWords.units)
        ...unit.items.take(wordsPerFamily).map((LearningItem item) => item.key),
    ];
  }
}

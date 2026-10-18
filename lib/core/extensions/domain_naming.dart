import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the learning domains and of their units, shared by every
/// screen that shows a unit: the path, the quiz, the profile, the badges.
///
/// A new domain adds its name to `commonDomainName` and a case to each
/// method here; nothing else changes on the screens.
extension DomainNaming on AppLocalizations {
  /// Name of the domain [domainId], such as "Nombres".
  String domainName(String domainId) => commonDomainName(domainId);

  /// Name of the unit [number] of [domainId], such as "Table de 5" or
  /// "Compter jusqu'à 10".
  String unitName(String domainId, int number) {
    return switch (domainId) {
      LearningDomainIds.multiplication => quizMultiplicationUnit(number),
      LearningDomainIds.numbers => numbersUnitName('$number'),
      _ => '',
    };
  }

  /// Short mark of the unit [number] of [domainId] on its badge, such as
  /// "×5" or "<>".
  String unitMark(String domainId, int number) {
    return switch (domainId) {
      LearningDomainIds.multiplication => '×$number',
      LearningDomainIds.numbers
          when number >= 1 && number <= _numbersMarks.length =>
        _numbersMarks[number - 1],
      _ => '$number',
    };
  }

  /// Tip of the unit [number] of [domainId], shown at its Discovery
  /// stage.
  String unitTip(String domainId, int number) {
    return switch (domainId) {
      LearningDomainIds.multiplication => pathMultiplicationTip('$number'),
      LearningDomainIds.numbers => numbersUnitTip('$number'),
      _ => '',
    };
  }

  /// Marks of the seven units of the numbers: digits and signs, the same
  /// in every language.
  static const List<String> _numbersMarks = <String>[
    '10',
    '20',
    '100',
    '34',
    '<>',
    '123',
    '±1',
  ];
}

import 'package:kid_matix/core/extensions/domain_names/addition_names.dart';
import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/core/extensions/domain_names/multiplication_names.dart';
import 'package:kid_matix/core/extensions/domain_names/number_names.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the learning domains and of their units, shared by every
/// screen that shows a unit: the path, the quiz, the Profile, the badges,
/// the challenges.
///
/// A new domain writes its [DomainNames] next to the others and adds one
/// line to [_names]; no screen changes.
extension DomainNaming on AppLocalizations {
  static const Map<String, DomainNames> _names = <String, DomainNames>{
    LearningDomainIds.multiplication: MultiplicationNames(),
    LearningDomainIds.numbers: NumberNames(),
    LearningDomainIds.addition: AdditionNames(),
  };

  /// The names of [domainId], or `null` when the domain has none.
  static DomainNames? namesOf(String domainId) => _names[domainId];

  /// Name of the domain [domainId], such as "Nombres"; empty when it has
  /// no names.
  String domainName(String domainId) {
    return _names[domainId]?.domainName(this) ?? '';
  }

  /// Name of the unit [unitKey] of [domainId], such as "Table de 5" or
  /// "Compter jusqu'à 10".
  String unitName(String domainId, String unitKey) {
    return _names[domainId]?.unitName(this, _slugOf(unitKey)) ?? '';
  }

  /// Short mark of the unit [unitKey] of [domainId] on its badge, such as
  /// "×5" or "<>".
  String unitMark(String domainId, String unitKey) {
    return _names[domainId]?.unitMark(_slugOf(unitKey)) ?? '';
  }

  /// Tip of the unit [unitKey] of [domainId], shown at its Discovery
  /// stage.
  String unitTip(String domainId, String unitKey) {
    return _names[domainId]?.unitTip(this, _slugOf(unitKey)) ?? '';
  }

  /// Title of the mastery grid of [domainId] in the Profile, such as "Mes
  /// tables".
  String gridTitle(String domainId) {
    return _names[domainId]?.gridTitle(this) ?? '';
  }

  /// The part of [unitKey] after its domain prefix: `5` for `mul:5`.
  static String _slugOf(String unitKey) {
    return unitKey.substring(unitKey.indexOf(':') + 1);
  }
}

import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the units of the numbers up to 100, by slug.
final class NumberNames implements DomainNames {
  /// Creates the names.
  const NumberNames();

  /// Marks of the units: digits and signs, the same in every language.
  static const Map<String, String> _marks = <String, String>{
    'count10': '10',
    'count20': '20',
    'count100': '100',
    'tensones': '34',
    'compare': '<>',
    'order': '123',
    'beforeafter': '±1',
  };

  @override
  String domainName(AppLocalizations l10n) => l10n.numbersDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    return _marks.containsKey(slug) ? l10n.numbersUnitName(slug) : '';
  }

  @override
  String unitMark(String slug) => _marks[slug] ?? '';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    return _marks.containsKey(slug) ? l10n.numbersUnitTip(slug) : '';
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitleNumbers;
}

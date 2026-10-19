import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the families of the math words, by slug.
final class MathWordNames implements DomainNames {
  /// Creates the names.
  const MathWordNames();

  /// Marks of the families: signs the same in every language.
  static const Map<String, String> _marks = <String, String>{
    'add': '+',
    'remove': '−',
    'compare': '=',
    'group': '×',
    'share': '÷',
    'ask': '?',
  };

  @override
  String domainName(AppLocalizations l10n) => l10n.mathWordsDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    return _marks.containsKey(slug) ? l10n.mathWordsUnitName(slug) : '';
  }

  @override
  String unitMark(String slug) => _marks[slug] ?? '';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    return _marks.containsKey(slug) ? l10n.mathWordsUnitTip(slug) : '';
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitleMathWords;
}

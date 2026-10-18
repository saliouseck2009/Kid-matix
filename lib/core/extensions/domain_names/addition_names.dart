import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the units of the additions and subtractions, by slug.
final class AdditionNames implements DomainNames {
  /// Creates the names.
  const AdditionNames();

  /// Marks of the units: signs and digits, the same in every language.
  static const Map<String, String> _marks = <String, String>{
    'add10': '+10',
    'toten': '10',
    'add20': '+20',
    'sub10': '−10',
    'sub20': '−20',
    'add100': '+50',
    'sub100': '−50',
    'carry': '+99',
    'borrow': '−99',
  };

  @override
  String domainName(AppLocalizations l10n) => l10n.additionDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    return _marks.containsKey(slug) ? l10n.additionUnitName(slug) : '';
  }

  @override
  String unitMark(String slug) => _marks[slug] ?? '';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    return _marks.containsKey(slug) ? l10n.additionUnitTip(slug) : '';
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitleAddition;
}

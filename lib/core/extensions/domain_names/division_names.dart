import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the units of the division: the slug is the divisor, from 1 to
/// 12, as the number of the multiplication table it reverses.
final class DivisionNames implements DomainNames {
  /// Creates the names.
  const DivisionNames();

  static const int _lastDivisor = 12;

  @override
  String domainName(AppLocalizations l10n) => l10n.divisionDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    final int? divisor = _divisorOf(slug);
    return divisor == null ? '' : l10n.divisionUnitName(divisor);
  }

  @override
  String unitMark(String slug) => _divisorOf(slug) == null ? '' : '÷$slug';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    return _divisorOf(slug) == null ? '' : l10n.divisionUnitTip(slug);
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitleDivision;

  /// The divisor told by [slug], or `null` outside 1 to 12.
  static int? _divisorOf(String slug) {
    final int? divisor = int.tryParse(slug);
    if (divisor == null || divisor < 1 || divisor > _lastDivisor) return null;
    return divisor;
  }
}

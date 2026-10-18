import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the multiplication tables: the slug is the number of the
/// table.
final class MultiplicationNames implements DomainNames {
  /// Creates the names.
  const MultiplicationNames();

  @override
  String domainName(AppLocalizations l10n) => l10n.multiplicationDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    final int? table = int.tryParse(slug);
    return table == null ? '' : l10n.quizMultiplicationUnit(table);
  }

  @override
  String unitMark(String slug) => int.tryParse(slug) == null ? '' : '×$slug';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    return int.tryParse(slug) == null ? '' : l10n.pathMultiplicationTip(slug);
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitle;
}

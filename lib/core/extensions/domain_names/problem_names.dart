import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the units of the word problems, by slug: a level and a number
/// (`img1`, `short2`, `full1`), or the traps of a level (`trap2`). A name
/// says the level, never an operation.
final class ProblemNames implements DomainNames {
  /// Creates the names.
  const ProblemNames();

  /// Marks of the units: the level, or an exclamation mark for the traps.
  /// Signs the same in every language.
  static const Map<String, String> _marks = <String, String>{
    'img': '1',
    'short': '2',
    'full': '3',
    'trap': '!',
  };

  /// The kind and the number of [slug], or `null` when it is not a unit.
  static (String, String)? _partsOf(String slug) {
    for (final String kind in _marks.keys) {
      final String number = slug.substring(kind.length.clamp(0, slug.length));
      if (slug.startsWith(kind) && RegExp(r'^\d$').hasMatch(number)) {
        return (kind, number);
      }
    }
    return null;
  }

  @override
  String domainName(AppLocalizations l10n) => l10n.problemsDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    final (String, String)? parts = _partsOf(slug);
    return parts == null ? '' : l10n.problemsUnitName(parts.$1, parts.$2);
  }

  @override
  String unitMark(String slug) => _marks[_partsOf(slug)?.$1] ?? '';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    final (String, String)? parts = _partsOf(slug);
    return parts == null ? '' : l10n.problemsUnitTip(parts.$1);
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitleProblems;
}

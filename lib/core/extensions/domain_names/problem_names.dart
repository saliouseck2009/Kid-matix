import 'package:kid_matix/core/extensions/domain_names/domain_names.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the units of the word problems, by slug: an operation and a
/// level (`add1`, `div3`), or the traps of a level (`trap2`).
final class ProblemNames implements DomainNames {
  /// Creates the names.
  const ProblemNames();

  /// The real operation of each unit slug prefix, as the texts select it.
  static const Map<String, String> _operations = <String, String>{
    'add': 'add',
    'sub': 'subtract',
    'mul': 'multiply',
    'div': 'divide',
    'trap': 'trap',
  };

  /// Marks of the units: signs the same in every language.
  static const Map<String, String> _marks = <String, String>{
    'add': '+',
    'sub': '−',
    'mul': '×',
    'div': '÷',
    'trap': '!',
  };

  static String? _prefixOf(String slug) {
    for (final String prefix in _operations.keys) {
      if (slug.startsWith(prefix) && slug.length == prefix.length + 1) {
        return prefix;
      }
    }
    return null;
  }

  @override
  String domainName(AppLocalizations l10n) => l10n.problemsDomainName;

  @override
  String unitName(AppLocalizations l10n, String slug) {
    final String? prefix = _prefixOf(slug);
    if (prefix == null) return '';
    return l10n.problemsUnitName(
      _operations[prefix]!,
      slug.substring(prefix.length),
    );
  }

  @override
  String unitMark(String slug) => _marks[_prefixOf(slug)] ?? '';

  @override
  String unitTip(AppLocalizations l10n, String slug) {
    final String? prefix = _prefixOf(slug);
    return prefix == null ? '' : l10n.problemsUnitTip(_operations[prefix]!);
  }

  @override
  String gridTitle(AppLocalizations l10n) => l10n.masteryGridTitleProblems;
}

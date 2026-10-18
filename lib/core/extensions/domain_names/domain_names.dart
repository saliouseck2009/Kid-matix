import 'package:kid_matix/l10n/app_localizations.dart';

/// How the screens name one learning domain and its units.
///
/// A unit is told by its slug, the part of its key after the domain
/// prefix (`5` for `mul:5`, `compare` for `num:compare`), never by its
/// position, so adding a unit moves no name. Each domain has one, listed
/// in `DomainNaming`.
abstract interface class DomainNames {
  /// Name of the domain, such as "Nombres".
  String domainName(AppLocalizations l10n);

  /// Name of the unit [slug], such as "Table de 5" or "Comparer"; empty
  /// for a slug the domain lacks.
  String unitName(AppLocalizations l10n, String slug);

  /// Short mark of the unit [slug] on its badge, such as "×5" or "<>";
  /// empty for a slug the domain lacks.
  String unitMark(String slug);

  /// Tip of the unit [slug], shown at its Discovery stage; empty for a
  /// slug the domain lacks.
  String unitTip(AppLocalizations l10n, String slug);

  /// Title of the mastery grid of the domain in the Profile, such as
  /// "Mes tables".
  String gridTitle(AppLocalizations l10n);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/l10n/app_localizations.dart';
import 'package:kid_matix/l10n/app_localizations_en.dart';
import 'package:kid_matix/l10n/app_localizations_es.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../features/quiz/helpers/quiz_fixtures.dart';

/// Guard of the naming of the domains: every unit of every registered
/// domain has a name, a tip and a mark in every language, and the domain
/// has its own names. A new domain that forgets them fails here.
void main() {
  final List<LearningDomain> domains = buildDomainRegistry().domains;
  final Map<String, AppLocalizations> languages = <String, AppLocalizations>{
    'fr': AppLocalizationsFr(),
    'en': AppLocalizationsEn(),
    'es': AppLocalizationsEs(),
  };

  for (final LearningDomain domain in domains) {
    test('names the domain ${domain.id}', () {
      // Assert
      expect(DomainNaming.namesOf(domain.id), isNotNull);
      for (final AppLocalizations l10n in languages.values) {
        expect(l10n.domainName(domain.id), isNotEmpty);
        expect(l10n.gridTitle(domain.id), isNotEmpty);
      }
    });
    test('names, marks and tips every unit of ${domain.id}', () {
      for (final MapEntry<String, AppLocalizations> language
          in languages.entries) {
        final Set<String> names = <String>{};
        for (final LearningUnit unit in domain.units) {
          // Act
          final String actualName = language.value.unitName(
            domain.id,
            unit.key,
          );
          // Assert
          final String reason = '${unit.key} in ${language.key}';
          expect(actualName, isNotEmpty, reason: reason);
          expect(
            language.value.unitMark(domain.id, unit.key),
            isNotEmpty,
            reason: reason,
          );
          expect(
            language.value.unitTip(domain.id, unit.key),
            isNotEmpty,
            reason: reason,
          );
          names.add(actualName);
        }
        expect(names, hasLength(domain.units.length));
      }
    });
  }
  test('says nothing for a unit or a domain it does not know', () {
    // Arrange
    final AppLocalizations l10n = AppLocalizationsFr();
    // Assert
    expect(l10n.unitName('numbers', 'num:unknown'), isEmpty);
    expect(l10n.unitMark('numbers', 'num:unknown'), isEmpty);
    expect(l10n.unitTip('numbers', 'num:unknown'), isEmpty);
    expect(l10n.unitName('multiplication', 'mul:x'), isEmpty);
    expect(l10n.domainName('unknown'), isEmpty);
    expect(DomainNaming.namesOf('unknown'), isNull);
  });
}

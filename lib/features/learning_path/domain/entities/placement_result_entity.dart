import 'package:meta/meta.dart';

/// A placement test kept with its date: a level per domain.
@immutable
final class PlacementResultEntity {
  /// Creates the result of the test taken at [takenAt].
  PlacementResultEntity({
    required this.takenAt,
    required List<DomainResultEntity> domains,
  }) : domains = List<DomainResultEntity>.unmodifiable(domains);

  /// When the test was finished.
  final DateTime takenAt;

  /// A level per domain of the test, in the order of the climb.
  final List<DomainResultEntity> domains;

  /// The row of the domain the test recommended starting with, or `null`
  /// when the child had every skill.
  DomainResultEntity? get recommended {
    for (final DomainResultEntity domain in domains) {
      if (domain.startUnitKey != null) return domain;
    }
    return null;
  }

  /// The level in [domainId], or `null` when the test did not check it.
  DomainResultEntity? domainOf(String domainId) {
    for (final DomainResultEntity domain in domains) {
      if (domain.domainId == domainId) return domain;
    }
    return null;
  }
}

/// The level of a child in one domain, as one test found it.
@immutable
final class DomainResultEntity {
  /// Creates the level in [domainId].
  const DomainResultEntity({
    required this.domainId,
    required this.level,
    required this.skillCount,
    required this.unitCount,
    this.startUnitKey,
  });

  /// Learning domain.
  final String domainId;

  /// Skills of the domain the child had; `null` when the test stopped
  /// before reaching the domain.
  final int? level;

  /// Skills the test checked in the domain.
  final int skillCount;

  /// Units of the domain the test opened.
  final int unitCount;

  /// Unit to start with when this is the domain recommended, else `null`.
  final String? startUnitKey;
}

import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:meta/meta.dart';

/// How far a player is in one learning domain, as « Mes parcours » shows
/// it: the units done, the crowns, and whether they ever played it.
@immutable
final class DomainProgressEntity {
  /// Creates the progress in [domainId].
  const DomainProgressEntity({
    required this.domainId,
    required this.doneUnitCount,
    required this.unitCount,
    required this.crownCount,
    required this.isStarted,
  });

  /// The progress shown by [path]: a unit is done once its gate stage has
  /// a star, as on the map; the domain is started once any stage has one.
  factory DomainProgressEntity.fromPath(LearningPathEntity path) {
    int done = 0;
    int crowns = 0;
    bool isStarted = false;
    for (final TablePathNode table in path.tables) {
      if (table.stageOf(LearningPathBuilder.gateStage).stars > 0) done++;
      if (table.crown != TableCrown.none) crowns++;
      if (table.totalStars > 0) isStarted = true;
    }
    return DomainProgressEntity(
      domainId: path.domainId,
      doneUnitCount: done,
      unitCount: path.tables.length,
      crownCount: crowns,
      isStarted: isStarted,
    );
  }

  /// Learning domain.
  final String domainId;

  /// Units whose gate stage has a star.
  final int doneUnitCount;

  /// Units of the domain.
  final int unitCount;

  /// Units whose boss is defeated.
  final int crownCount;

  /// Whether the player earned a star in the domain.
  final bool isStarted;

  /// Whether every unit of the domain is done.
  bool get isFinished => unitCount > 0 && doneUnitCount == unitCount;

  /// Done fraction of the units, from 0 to 1.
  double get doneFraction => unitCount == 0 ? 0 : doneUnitCount / unitCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainProgressEntity &&
          other.domainId == domainId &&
          other.doneUnitCount == doneUnitCount &&
          other.unitCount == unitCount &&
          other.crownCount == crownCount &&
          other.isStarted == isStarted;

  @override
  int get hashCode =>
      Object.hash(domainId, doneUnitCount, unitCount, crownCount, isStarted);

  @override
  String toString() =>
      'DomainProgressEntity($domainId: $doneUnitCount/$unitCount, '
      '$crownCount crowns, started: $isStarted)';
}

/// Every domain of a player with its progress, and the one their latest
/// placement test recommended.
@immutable
final class PathOverviewEntity {
  /// Creates the overview of [domains].
  PathOverviewEntity({
    required List<DomainProgressEntity> domains,
    this.recommendedDomainId,
  }) : domains = List<DomainProgressEntity>.unmodifiable(domains);

  /// The progress in every domain, in registration order.
  final List<DomainProgressEntity> domains;

  /// The domain the latest placement test recommended starting with, or
  /// `null` when there is none or it is finished.
  final String? recommendedDomainId;
}

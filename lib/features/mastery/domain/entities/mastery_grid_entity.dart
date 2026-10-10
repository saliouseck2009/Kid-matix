import 'package:kid_matix/features/mastery/domain/entities/item_mastery_entity.dart';
import 'package:meta/meta.dart';

/// The status of every item of a domain for one player, one row per unit
/// in the natural order: for multiplication, 12 rows of 10 facts.
@immutable
final class MasteryGridEntity {
  /// Creates the grid.
  MasteryGridEntity({
    required this.domainId,
    required Map<String, List<ItemMasteryEntity>> rows,
  }) : rows = Map<String, List<ItemMasteryEntity>>.unmodifiable(
         rows.map(
           (String unitKey, List<ItemMasteryEntity> cells) =>
               MapEntry<String, List<ItemMasteryEntity>>(
                 unitKey,
                 List<ItemMasteryEntity>.unmodifiable(cells),
               ),
         ),
       );

  /// Learning domain of the grid.
  final String domainId;

  /// Cells of each unit, keyed by unit key in the natural order.
  final Map<String, List<ItemMasteryEntity>> rows;
}

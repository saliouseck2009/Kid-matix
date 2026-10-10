import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:meta/meta.dart';

/// One cell of the mastery grid: an item and its status.
@immutable
final class ItemMasteryEntity {
  /// Creates the cell.
  const ItemMasteryEntity({required this.itemKey, required this.status});

  /// Key of the item, such as `mul:7x8`.
  final String itemKey;

  /// What the player is shown about it.
  final MasteryStatus status;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ItemMasteryEntity &&
            other.itemKey == itemKey &&
            other.status == status;
  }

  @override
  int get hashCode => Object.hash(itemKey, status);

  @override
  String toString() => '$itemKey ${status.name}';
}

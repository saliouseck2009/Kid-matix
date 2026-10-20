import 'package:meta/meta.dart';

/// One item the class stumbles on: « 8 élèves se trompent sur 7 × 8 ».
@immutable
final class ItemStruggle {
  /// Creates the struggle of [pupilIds] on [itemKey].
  const ItemStruggle({required this.itemKey, required this.pupilIds});

  /// Item, such as `mul:7x8`.
  final String itemKey;

  /// Pupils stuck on it, in the order of the class list.
  final List<String> pupilIds;

  /// How many pupils are stuck on it.
  int get pupilCount => pupilIds.length;

  /// Returns a copy with the given fields replaced.
  ItemStruggle copyWith({String? itemKey, List<String>? pupilIds}) {
    return ItemStruggle(
      itemKey: itemKey ?? this.itemKey,
      pupilIds: pupilIds ?? this.pupilIds,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ItemStruggle &&
            other.itemKey == itemKey &&
            other.pupilIds.join(',') == pupilIds.join(',');
  }

  @override
  int get hashCode => Object.hash(itemKey, Object.hashAll(pupilIds));

  @override
  String toString() => 'ItemStruggle($itemKey, $pupilCount)';
}

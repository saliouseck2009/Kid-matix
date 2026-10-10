import 'package:kid_matix/core/quiz/learning_item.dart';

/// A group of items that forms one world of the learning path.
///
/// For the multiplication domain, one table such as the table of 7.
abstract interface class LearningUnit {
  /// Stable key, such as `mul:7`.
  String get key;

  /// Number shown to name the unit, such as 7 for "Table de 7".
  int get number;

  /// Items of the unit, in their natural order.
  List<LearningItem> get items;
}

import 'package:kid_matix/core/quiz/learning_item.dart';

/// A group of items that forms one world of the learning path.
///
/// For the multiplication domain, one table such as the table of 7.
abstract interface class LearningUnit {
  /// Stable key, such as `mul:7`.
  String get key;

  /// Items of the unit, in their natural order.
  List<LearningItem> get items;
}

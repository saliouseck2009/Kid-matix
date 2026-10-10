import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:meta/meta.dart';

/// The help card of an item missed twice in a quiz: every fact of its
/// unit, and a picture of the item when the domain has one.
@immutable
final class ItemHelp {
  /// Creates the help of the [itemIndex]th fact of [unitFacts].
  ItemHelp({
    required List<List<PromptToken>> unitFacts,
    required this.itemIndex,
    this.dotGrid,
  }) : unitFacts = List<List<PromptToken>>.unmodifiable(
         unitFacts.map(List<PromptToken>.unmodifiable),
       );

  /// Every fact of the unit with its answer, in the natural order: for
  /// 7 x 8, the table of 7 from `7 × 1 = 7` to `7 × 10 = 70`.
  final List<List<PromptToken>> unitFacts;

  /// Position of the item in [unitFacts], highlighted on the card.
  final int itemIndex;

  /// Dots that picture the item, or `null` when the domain has none.
  final DotGrid? dotGrid;
}

/// A grid of dots: 7 rows of 8 dots pictures 7 x 8.
@immutable
final class DotGrid {
  /// Creates a grid of [rows] rows of [columns] dots.
  const DotGrid({required this.rows, required this.columns});

  /// Number of rows.
  final int rows;

  /// Dots per row.
  final int columns;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DotGrid && other.rows == rows && other.columns == columns;
  }

  @override
  int get hashCode => Object.hash(rows, columns);
}

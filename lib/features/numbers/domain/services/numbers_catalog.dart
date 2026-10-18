import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/numbers/domain/entities/number_item.dart';
import 'package:kid_matix/features/numbers/domain/entities/numbers_unit.dart';

/// The seven units of the numbers up to 100 and their items, ten each, in
/// the order of the learning path.
///
/// Every key here is released content: changing one loses the progress
/// stored under it. Add items or units, never rename them.
abstract final class NumbersCatalog {
  /// Positions of the blank tick on the lines of [order], from 0.
  static const int _second = 1;
  static const int _third = 2;
  static const int _fourth = 3;

  /// 1. Compter jusqu'à 10: 1 to 10 objects.
  static final NumbersUnit count10 = NumbersUnit(
    slug: 'count10',
    number: 1,
    items: <NumberItem>[
      for (int count = 1; count <= 10; count++) CountItem(count),
    ],
  );

  /// 2. Compter jusqu'à 20: 11 to 20 objects, a full block of ten first.
  static final NumbersUnit count20 = NumbersUnit(
    slug: 'count20',
    number: 2,
    items: <NumberItem>[
      for (int count = 11; count <= 20; count++) CountItem(count),
    ],
  );

  /// 3. Compter jusqu'à 100: 1 to 10 bundles of ten.
  static final NumbersUnit count100 = NumbersUnit(
    slug: 'count100',
    number: 3,
    items: <NumberItem>[
      for (int tens = 1; tens <= 10; tens++)
        TensOnesItem(
          tens * TenBundlesPicture.sticksPerBundle,
          isWholeTens: true,
        ),
    ],
  );

  /// 4. Dizaines et unités: two-digit numbers whose digits differ, so the
  /// swapped digits are always a wrong answer.
  static final NumbersUnit tensAndOnes = NumbersUnit(
    slug: 'tensones',
    number: 4,
    items: <NumberItem>[
      for (final int value in <int>[13, 21, 34, 45, 52, 59, 67, 76, 83, 98])
        TensOnesItem(value),
    ],
  );

  /// 5. Comparer: four smaller, four greater, two equal.
  static final NumbersUnit compare = NumbersUnit(
    slug: 'compare',
    number: 5,
    items: const <NumberItem>[
      CompareItem(3, 8),
      CompareItem(9, 6),
      CompareItem(12, 21),
      CompareItem(15, 15),
      CompareItem(34, 43),
      CompareItem(58, 49),
      CompareItem(76, 67),
      CompareItem(80, 80),
      CompareItem(91, 19),
      CompareItem(99, 100),
    ],
  );

  /// 6. Ranger: numbers in order on a line, counting by 2, 5 or 10.
  static final NumbersUnit order = NumbersUnit(
    slug: 'order',
    number: 6,
    items: const <NumberItem>[
      NumberLineItem(missing: 8, step: 2, blankIndex: _fourth),
      NumberLineItem(missing: 14, step: 2, blankIndex: _third),
      NumberLineItem(missing: 15, step: 5, blankIndex: _third),
      NumberLineItem(missing: 26, step: 2, blankIndex: _third),
      NumberLineItem(missing: 30, step: 10, blankIndex: _third),
      NumberLineItem(missing: 40, step: 5, blankIndex: _fourth),
      NumberLineItem(missing: 55, step: 5, blankIndex: _second),
      NumberLineItem(missing: 70, step: 10, blankIndex: _fourth),
      NumberLineItem(missing: 85, step: 5, blankIndex: _third),
      NumberLineItem(missing: 90, step: 10, blankIndex: _fourth),
    ],
  );

  /// 7. Avant et après: the number just before or just after, most of
  /// them across a ten.
  static final NumbersUnit beforeAfter = NumbersUnit(
    slug: 'beforeafter',
    number: 7,
    items: const <NumberItem>[
      NeighborItem(reference: 5, isAfter: true),
      NeighborItem(reference: 7, isAfter: false),
      NeighborItem(reference: 9, isAfter: true),
      NeighborItem(reference: 10, isAfter: false),
      NeighborItem(reference: 19, isAfter: true),
      NeighborItem(reference: 30, isAfter: false),
      NeighborItem(reference: 39, isAfter: true),
      NeighborItem(reference: 61, isAfter: false),
      NeighborItem(reference: 80, isAfter: false),
      NeighborItem(reference: 99, isAfter: true),
    ],
  );

  /// Every unit, in the order of the learning path.
  static final List<NumbersUnit> units = List<NumbersUnit>.unmodifiable(
    <NumbersUnit>[
      count10,
      count20,
      count100,
      tensAndOnes,
      compare,
      order,
      beforeAfter,
    ],
  );
}

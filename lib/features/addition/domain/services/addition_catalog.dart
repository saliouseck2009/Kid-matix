import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_unit.dart';

/// The eighteen units of the additions and subtractions and their facts,
/// in the order of the learning path, easy to hard.
///
/// Every addition `a + b` with `a` and `b` from 1 to 9 is taught, in both
/// orders, in the unit of its sum, and so is every subtraction of its
/// family (`c − a` and `c − b`, `c = a + b`), exactly once. Facts with 0 or
/// with a term of 10 or more are left out on purpose. The sum 10 is in the
/// complements to 10 (`toten`) and `10 − 1` to `10 − 9` in `subten`.
/// Fact families stay inside the units of the same sums, so a mistake on
/// `7 + 8` can recall `8 + 7`, and `15 − 7` recalls `15 − 8`.
///
/// Every key here is released content: changing one loses the progress
/// stored under it. Add facts or units, never rename them.
abstract final class AdditionCatalog {
  static ArithmeticFact _add(int left, int right) =>
      ArithmeticFact.add(left, right);

  static ArithmeticFact _sub(int left, int right) =>
      ArithmeticFact.subtract(left, right);

  /// Largest term of a fact up to 20.
  static const int _largestTerm = 9;

  /// Every addition whose sum is from [first] to [last], sum by sum, the
  /// smaller left term first: `2 + 3`, `3 + 2` for the sum 5.
  static List<ArithmeticFact> _additionsOfSums(int first, int last) {
    return <ArithmeticFact>[
      for (int sum = first; sum <= last; sum++)
        for (int left = 1; left <= _largestTerm; left++)
          if (sum - left >= 1 && sum - left <= _largestTerm)
            _add(left, sum - left),
    ];
  }

  /// Every subtraction of the wholes from [first] to [last] whose two
  /// parts are from 1 to 9: `5 − 2`, `5 − 3`...
  static List<ArithmeticFact> _subtractionsOfWholes(int first, int last) {
    return <ArithmeticFact>[
      for (int whole = first; whole <= last; whole++)
        for (int part = 1; part <= _largestTerm; part++)
          if (whole - part >= 1 && whole - part <= _largestTerm)
            _sub(whole, part),
    ];
  }

  /// 1. Additions jusqu'à 5: the sums 2 to 5.
  static final ArithmeticUnit add5 = ArithmeticUnit(
    slug: 'add5',
    number: 1,
    aid: ArithmeticAid.numberLine,
    facts: _additionsOfSums(2, 5),
  );

  /// 2. Soustractions jusqu'à 5: the families of the sums 2 to 5.
  static final ArithmeticUnit sub5 = ArithmeticUnit(
    slug: 'sub5',
    number: 2,
    aid: ArithmeticAid.numberLine,
    facts: _subtractionsOfWholes(2, 5),
  );

  /// 3. Additions jusqu'à 7: the sums 6 and 7.
  static final ArithmeticUnit add7 = ArithmeticUnit(
    slug: 'add7',
    number: 3,
    aid: ArithmeticAid.numberLine,
    facts: _additionsOfSums(6, 7),
  );

  /// 4. Additions jusqu'à 9: the sums 8 and 9.
  static final ArithmeticUnit add9 = ArithmeticUnit(
    slug: 'add9',
    number: 4,
    aid: ArithmeticAid.numberLine,
    facts: _additionsOfSums(8, 9),
  );

  /// 5. Compléments à 10: what to add to 1 to 9 to make 10.
  static final ArithmeticUnit toTen = ArithmeticUnit(
    slug: 'toten',
    number: 5,
    aid: ArithmeticAid.completeToTen,
    facts: _additionsOfSums(10, 10),
  );

  /// 6. Soustractions jusqu'à 7: the families of the sums 6 and 7.
  static final ArithmeticUnit sub7 = ArithmeticUnit(
    slug: 'sub7',
    number: 6,
    aid: ArithmeticAid.numberLine,
    facts: _subtractionsOfWholes(6, 7),
  );

  /// 7. Soustractions jusqu'à 9: the families of the sums 8 and 9.
  static final ArithmeticUnit sub9 = ArithmeticUnit(
    slug: 'sub9',
    number: 7,
    aid: ArithmeticAid.numberLine,
    facts: _subtractionsOfWholes(8, 9),
  );

  /// 8. Soustractions à partir de 10: `10 − 1` to `10 − 9`.
  static final ArithmeticUnit subTen = ArithmeticUnit(
    slug: 'subten',
    number: 8,
    aid: ArithmeticAid.completeToTen,
    facts: _subtractionsOfWholes(10, 10),
  );

  /// 9. Additions jusqu'à 12: the sums 11 and 12, which cross the ten.
  static final ArithmeticUnit add12 = ArithmeticUnit(
    slug: 'add12',
    number: 9,
    aid: ArithmeticAid.numberLine,
    facts: _additionsOfSums(11, 12),
  );

  /// 10. Additions jusqu'à 14: the sums 13 and 14.
  static final ArithmeticUnit add14 = ArithmeticUnit(
    slug: 'add14',
    number: 10,
    aid: ArithmeticAid.numberLine,
    facts: _additionsOfSums(13, 14),
  );

  /// 11. Additions jusqu'à 20: the sums 15 to 18.
  static final ArithmeticUnit add20 = ArithmeticUnit(
    slug: 'add20',
    number: 11,
    aid: ArithmeticAid.numberLine,
    facts: _additionsOfSums(15, 18),
  );

  /// 12. Soustractions jusqu'à 12: the families of the sums 11 and 12.
  static final ArithmeticUnit sub12 = ArithmeticUnit(
    slug: 'sub12',
    number: 12,
    aid: ArithmeticAid.numberLine,
    facts: _subtractionsOfWholes(11, 12),
  );

  /// 13. Soustractions jusqu'à 14: the families of the sums 13 and 14.
  static final ArithmeticUnit sub14 = ArithmeticUnit(
    slug: 'sub14',
    number: 13,
    aid: ArithmeticAid.numberLine,
    facts: _subtractionsOfWholes(13, 14),
  );

  /// 14. Soustractions jusqu'à 20: the families of the sums 15 to 18.
  static final ArithmeticUnit sub20 = ArithmeticUnit(
    slug: 'sub20',
    number: 14,
    aid: ArithmeticAid.numberLine,
    facts: _subtractionsOfWholes(15, 18),
  );

  /// 15. Additions jusqu'à 100 sans retenue: the ones make less than 10.
  static final ArithmeticUnit add100 = ArithmeticUnit(
    slug: 'add100',
    number: 15,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _add(23, 14),
      _add(31, 25),
      _add(42, 36),
      _add(15, 44),
      _add(52, 27),
      _add(61, 38),
      _add(34, 45),
      _add(71, 26),
      _add(18, 61),
      _add(53, 32),
    ],
  );

  /// 16. Soustractions jusqu'à 100 sans retenue: the ones can be taken.
  static final ArithmeticUnit sub100 = ArithmeticUnit(
    slug: 'sub100',
    number: 16,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _sub(47, 23),
      _sub(58, 34),
      _sub(69, 25),
      _sub(86, 42),
      _sub(75, 31),
      _sub(98, 57),
      _sub(64, 12),
      _sub(79, 45),
      _sub(55, 21),
      _sub(88, 63),
    ],
  );

  /// 17. Additions avec retenue: the ones make 10 or more.
  static final ArithmeticUnit carry = ArithmeticUnit(
    slug: 'carry',
    number: 17,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _add(27, 15),
      _add(38, 24),
      _add(46, 37),
      _add(19, 25),
      _add(58, 26),
      _add(35, 48),
      _add(67, 18),
      _add(29, 34),
      _add(75, 16),
      _add(49, 43),
    ],
  );

  /// 18. Soustractions avec retenue: a ten is broken to take the ones.
  static final ArithmeticUnit borrow = ArithmeticUnit(
    slug: 'borrow',
    number: 18,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _sub(42, 17),
      _sub(63, 28),
      _sub(51, 26),
      _sub(74, 38),
      _sub(85, 49),
      _sub(92, 67),
      _sub(56, 29),
      _sub(81, 35),
      _sub(70, 43),
      _sub(64, 36),
    ],
  );

  /// Every unit, in the order of the learning path.
  static final List<ArithmeticUnit> units = List<ArithmeticUnit>.unmodifiable(
    <ArithmeticUnit>[
      add5,
      sub5,
      add7,
      add9,
      toTen,
      sub7,
      sub9,
      subTen,
      add12,
      add14,
      add20,
      sub12,
      sub14,
      sub20,
      add100,
      sub100,
      carry,
      borrow,
    ],
  );
}

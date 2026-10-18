import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_unit.dart';

/// The fifteen units of the additions and subtractions and their facts, in
/// the order of the learning path, easy to hard.
///
/// The units up to 20 are built from fact families: the subtractions of
/// each `sub` unit are the families of the additions of the `add` unit with
/// the same sums, so a mistake on `7 + 8` can recall `8 + 7`, and `15 − 7`
/// recalls `15 − 8`. The additions up to 20 hold every crossing of the ten
/// (9 + 2 to 9 + 9, 8 + 3 to 8 + 9, 7 + 4 to 7 + 9, 6 + 5 to 6 + 9) and the
/// doubles 6 + 6 to 9 + 9. The doubles 1 + 1 to 4 + 4 are in the first two
/// units; 5 + 5 is in the complements to 10, since a fact lives in one
/// unit only.
///
/// Every key here is released content: changing one loses the progress
/// stored under it. Add facts or units, never rename them.
abstract final class AdditionCatalog {
  static ArithmeticFact _add(int left, int right) =>
      ArithmeticFact.add(left, right);

  static ArithmeticFact _sub(int left, int right) =>
      ArithmeticFact.subtract(left, right);

  /// The two orders of each pair: `(2, 3)` gives `2 + 3` and `3 + 2`; a
  /// double such as `(3, 3)` gives one fact.
  static List<ArithmeticFact> _bothWays(List<(int, int)> pairs) {
    return <ArithmeticFact>[
      for (final (int a, int b) in pairs) ...<ArithmeticFact>[
        _add(a, b),
        if (a != b) _add(b, a),
      ],
    ];
  }

  /// Both subtractions of each whole: `(15, 7)` gives `15 − 7` and
  /// `15 − 8`; `(8, 4)` gives `8 − 4` only.
  static List<ArithmeticFact> _bothTakeAways(List<(int, int)> wholes) {
    return <ArithmeticFact>[
      for (final (int whole, int part) in wholes) ...<ArithmeticFact>[
        _sub(whole, part),
        if (part != whole - part) _sub(whole, whole - part),
      ],
    ];
  }

  /// 1. Additions jusqu'à 5: sums from 2 to 5, both orders.
  static final ArithmeticUnit add5 = ArithmeticUnit(
    slug: 'add5',
    number: 1,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (1, 1),
      (1, 2),
      (1, 3),
      (2, 2),
      (2, 3),
      (1, 4),
    ]),
  );

  /// 2. Additions jusqu'à 10: sums from 6 to 9, both orders.
  static final ArithmeticUnit add10 = ArithmeticUnit(
    slug: 'add10',
    number: 2,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (3, 3),
      (2, 4),
      (1, 5),
      (3, 4),
      (2, 5),
      (4, 4),
      (3, 5),
      (4, 5),
    ]),
  );

  /// 3. Compléments à 10: what to add to 1 to 9 to make 10.
  static final ArithmeticUnit toTen = ArithmeticUnit(
    slug: 'toten',
    number: 3,
    aid: ArithmeticAid.completeToTen,
    facts: <ArithmeticFact>[
      for (int left = 1; left <= 9; left++) _add(left, 10 - left),
    ],
  );

  /// 4. Soustractions jusqu'à 5: the families of the additions up to 5.
  static final ArithmeticUnit sub5 = ArithmeticUnit(
    slug: 'sub5',
    number: 4,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (2, 1),
      (3, 1),
      (4, 1),
      (4, 2),
      (5, 2),
      (5, 1),
    ]),
  );

  /// 5. Soustractions jusqu'à 10: the families of the additions up to 10.
  static final ArithmeticUnit sub10 = ArithmeticUnit(
    slug: 'sub10',
    number: 5,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (6, 3),
      (6, 2),
      (6, 1),
      (7, 3),
      (7, 2),
      (8, 4),
      (8, 3),
      (9, 4),
    ]),
  );

  /// 6. Additions jusqu'à 12: the sums 11 and 12, which cross the ten.
  static final ArithmeticUnit add12 = ArithmeticUnit(
    slug: 'add12',
    number: 6,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (2, 9),
      (3, 8),
      (4, 7),
      (5, 6),
      (3, 9),
      (4, 8),
      (5, 7),
      (6, 6),
    ]),
  );

  /// 7. Additions jusqu'à 14: the sums 13 and 14.
  static final ArithmeticUnit add14 = ArithmeticUnit(
    slug: 'add14',
    number: 7,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (4, 9),
      (5, 8),
      (6, 7),
      (5, 9),
      (6, 8),
      (7, 7),
    ]),
  );

  /// 8. Additions jusqu'à 20: the sums 15 to 18.
  static final ArithmeticUnit add20 = ArithmeticUnit(
    slug: 'add20',
    number: 8,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (6, 9),
      (7, 8),
      (7, 9),
      (8, 8),
      (8, 9),
      (9, 9),
    ]),
  );

  /// 9. Soustractions jusqu'à 12: the families of the sums 11 and 12.
  static final ArithmeticUnit sub12 = ArithmeticUnit(
    slug: 'sub12',
    number: 9,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (11, 2),
      (11, 3),
      (11, 4),
      (11, 5),
      (12, 3),
      (12, 4),
      (12, 5),
      (12, 6),
    ]),
  );

  /// 10. Soustractions jusqu'à 14: the families of the sums 13 and 14.
  static final ArithmeticUnit sub14 = ArithmeticUnit(
    slug: 'sub14',
    number: 10,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (13, 4),
      (13, 5),
      (13, 6),
      (14, 5),
      (14, 6),
      (14, 7),
    ]),
  );

  /// 11. Soustractions jusqu'à 20: the families of the sums 15 to 18.
  static final ArithmeticUnit sub20 = ArithmeticUnit(
    slug: 'sub20',
    number: 11,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (15, 6),
      (15, 7),
      (16, 7),
      (16, 8),
      (17, 8),
      (18, 9),
    ]),
  );

  /// 12. Additions jusqu'à 100 sans retenue: the ones make less than 10.
  static final ArithmeticUnit add100 = ArithmeticUnit(
    slug: 'add100',
    number: 12,
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

  /// 13. Soustractions jusqu'à 100 sans retenue: the ones can be taken.
  static final ArithmeticUnit sub100 = ArithmeticUnit(
    slug: 'sub100',
    number: 13,
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

  /// 14. Additions avec retenue: the ones make 10 or more.
  static final ArithmeticUnit carry = ArithmeticUnit(
    slug: 'carry',
    number: 14,
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

  /// 15. Soustractions avec retenue: a ten is broken to take the ones.
  static final ArithmeticUnit borrow = ArithmeticUnit(
    slug: 'borrow',
    number: 15,
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
      add10,
      toTen,
      sub5,
      sub10,
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

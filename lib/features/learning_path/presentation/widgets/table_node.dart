import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/star_row.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/unit_badge.dart';

/// A table on the map: its badge, and its stars once it has some.
class TableNode extends StatelessWidget {
  /// Creates the node of [table].
  const TableNode({
    required this.table,
    required this.labels,
    required this.onOpen,
    super.key,
  });

  static const double _size = 88;
  static const double _currentSize = 104;

  /// Table shown.
  final TablePathNode table;

  /// Texts of the path.
  final PathLabels labels;

  /// Opens the detail of the table; a locked table does nothing.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final bool isLocked = table.status == TableStatus.locked;
    final bool isCurrent = table.status == TableStatus.current;
    return Semantics(
      button: !isLocked,
      label: labels.describeTable(table),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isLocked ? null : onOpen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: <Widget>[
            UnitBadge(
              mark: labels.unitMark(table.number),
              size: isCurrent ? _currentSize : _size,
              style: switch (table.status) {
                TableStatus.current => UnitBadgeStyle.current,
                TableStatus.locked => UnitBadgeStyle.locked,
                TableStatus.done || TableStatus.open => UnitBadgeStyle.reached,
              },
            ),
            if (!isCurrent && table.averageStars > 0)
              StarRow(count: table.averageStars),
          ],
        ),
      ),
    );
  }
}

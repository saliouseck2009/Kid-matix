import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/current_table_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_dots.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_header.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/review_node.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/table_node.dart';

/// The scrolling map of the learning path: the tables zigzag down, joined
/// by dots, with a review after every group of 3 and a call card next to
/// the current table. The header, when given, stays above the map.
class PathMap extends StatefulWidget {
  /// Creates the map of [path].
  const PathMap({
    required this.path,
    required this.labels,
    required this.onOpenTable,
    required this.onPlay,
    this.header,
    this.mascot,
    super.key,
  });

  /// Tables, reviews and stars of the player.
  final LearningPathEntity path;

  /// Texts of the path.
  final PathLabels labels;

  /// Opens the detail of a table.
  final ValueChanged<String> onOpenTable;

  /// Starts a stage.
  final ValueChanged<StageSource> onPlay;

  /// Widgets of other features at the top of the map, or `null`.
  final PathHeaderSlots? header;

  /// The mascot, shown under the current table, or `null`.
  final Widget? mascot;

  @override
  State<PathMap> createState() => _PathMapState();
}

class _PathMapState extends State<PathMap> {
  /// Horizontal places of the tables, from -1 (left) to 1 (right).
  static const List<double> _zigzag = <double>[-0.6, 0.1, 0.6, 0.1];

  final GlobalKey _currentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? current = _currentKey.currentContext;
      if (current != null && current.mounted) {
        Scrollable.ensureVisible(current, alignment: 0.3);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    double? previousX;
    int tableIndex = 0;
    for (final PathNode node in widget.path.nodes) {
      final double x = switch (node) {
        TablePathNode(status: TableStatus.current) => -1,
        TablePathNode() => _zigzag[tableIndex % _zigzag.length],
        ReviewPathNode() => 0,
      };
      if (node is TablePathNode) tableIndex++;
      if (previousX != null) {
        rows.add(PathDots(fromX: previousX, toX: x));
      }
      previousX = x;
      rows.add(_buildRow(node, x));
      if (node case TablePathNode(status: TableStatus.current)) {
        if (widget.mascot case final Widget mascot) {
          rows.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.space8),
              child: mascot,
            ),
          );
        }
      }
    }
    final Widget map = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
    final PathHeaderSlots? slots = widget.header;
    if (slots == null) return map;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.space24,
            AppSizes.space24,
            AppSizes.space24,
            0,
          ),
          child: PathHeader(
            slots: slots,
            crowns: widget.path.tables
                .where((TablePathNode table) => table.crown != TableCrown.none)
                .length,
          ),
        ),
        Expanded(child: map),
      ],
    );
  }

  Widget _buildRow(PathNode node, double x) {
    return switch (node) {
      TablePathNode(status: TableStatus.current) => Row(
        key: _currentKey,
        spacing: AppSizes.space16,
        children: <Widget>[
          TableNode(
            table: node,
            labels: widget.labels,
            onOpen: () => widget.onOpenTable(node.unitKey),
          ),
          Expanded(
            child: CurrentTableCard(
              table: node,
              labels: widget.labels,
              onPlay: () => _playNext(node),
            ),
          ),
        ],
      ),
      TablePathNode() => Align(
        alignment: Alignment(x, 0),
        child: TableNode(
          table: node,
          labels: widget.labels,
          onOpen: () => widget.onOpenTable(node.unitKey),
        ),
      ),
      ReviewPathNode() => Center(
        child: ReviewNode(
          review: node,
          labels: widget.labels,
          onPlay: () => widget.onPlay(
            StageSource(unitKey: node.unitKey, stage: node.stage.kind),
          ),
        ),
      ),
    };
  }

  void _playNext(TablePathNode table) {
    final StageState? next = table.nextStage;
    if (next == null) return widget.onOpenTable(table.unitKey);
    widget.onPlay(StageSource(unitKey: table.unitKey, stage: next.kind));
  }
}

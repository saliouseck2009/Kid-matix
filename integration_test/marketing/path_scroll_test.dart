// Marketing shot: the map of the learning path scrolls from the table of
// 1 down to the table of 5, Awa's current one.
//   bash tool/marketing/record.sh android path_scroll

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_map.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/table_node.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// Length of the scroll itself.
const Duration _scrollTime = Duration(seconds: 4);

/// Table the scroll ends on.
const int _lastTable = 5;

void main() {
  initMarketingBinding();

  testWidgets('scrolls the map from the first table', (
    WidgetTester tester,
  ) async {
    // Arrange: the recording opens on the top of the map.
    await startApp(
      tester,
      seed: seedDemoPlayer,
      beforeRecording: () async {
        await waitFor(tester, findLabel('Jouer'));
        _mapScrollable(tester).jumpTo(0);
      },
    );
    // Act: down to the table of 5, centered on screen.
    await pause(tester, const Duration(milliseconds: 800));
    final ScrollPosition position = _mapScrollable(tester);
    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final double target =
        (tester.getCenter(_tableNode(_lastTable)).dy - screen.height / 2).clamp(
          0,
          position.maxScrollExtent,
        );
    final DateTime start = DateTime.now();
    while (DateTime.now().difference(start) < _scrollTime) {
      final double progress =
          DateTime.now().difference(start).inMilliseconds /
          _scrollTime.inMilliseconds;
      position.jumpTo(
        target * Curves.easeInOut.transform(progress.clamp(0, 1)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await endScenario(tester, hold: const Duration(milliseconds: 1500));
    // Assert
    expect(position.pixels, closeTo(target, 1));
  });
}

Finder _tableNode(int number) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is TableNode && widget.table.number == number,
    description: 'node of the table of $number',
  );
}

/// The scroll position of the map.
ScrollPosition _mapScrollable(WidgetTester tester) {
  return tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byType(PathMap),
          matching: find.byType(Scrollable),
        ),
      )
      .position;
}

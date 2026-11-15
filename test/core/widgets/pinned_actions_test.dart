import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/pinned_actions.dart';

import '../../helpers/pump_localized.dart';

void main() {
  group('PinnedActions', () {
    testWidgets('keeps the buttons in sight over a content that scrolls', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Act
      await pumpLocalized(
        tester,
        Scaffold(
          body: PinnedActions(
            actions: ActionRows(
              primary: TextButton(onPressed: () {}, child: const Text('main')),
              secondary: <Widget>[
                TextButton(onPressed: () {}, child: const Text('left')),
                TextButton(onPressed: () {}, child: const Text('right')),
              ],
            ),
            child: const Column(
              children: <Widget>[
                Text('top'),
                SizedBox(height: 2000),
                Text('bottom'),
              ],
            ),
          ),
        ),
      );
      // Assert: the content goes under the fold, the buttons do not.
      expect(find.text('main').hitTestable(), findsOneWidget);
      expect(find.text('left').hitTestable(), findsOneWidget);
      expect(find.text('right').hitTestable(), findsOneWidget);
      expect(find.text('bottom').hitTestable(), findsNothing);
      expect(
        tester.getTopLeft(find.text('left')).dy,
        tester.getTopLeft(find.text('right')).dy,
      );
      expect(
        tester.getTopLeft(find.text('main')).dy,
        lessThan(tester.getTopLeft(find.text('left')).dy),
      );
    });
  });
}

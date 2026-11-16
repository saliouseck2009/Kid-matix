import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/stat_tile.dart';

import '../../helpers/pump_localized.dart';

void main() {
  group('StatTileRow', () {
    testWidgets('gives every tile one size, even when a label wraps', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Act: the label of the last tile takes several lines.
      await pumpLocalized(
        tester,
        const Scaffold(
          body: StatTileRow(
            tiles: <Widget>[
              StatTile(value: '+130', label: 'XP', isHighlighted: true),
              StatTile(value: '9 / 10', label: 'réussies'),
              StatTile(value: '4,0 s', label: 'en moyenne par question'),
            ],
          ),
        ),
      );
      // Assert
      final List<Size> actualSizes = <Size>[
        for (final Element tile in find.byType(StatTile).evaluate()) tile.size!,
      ];
      expect(actualSizes.toSet(), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });
}

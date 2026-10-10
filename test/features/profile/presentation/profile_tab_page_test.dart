import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/presentation/pages/profile_tab_page.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

void main() {
  group('ProfileTabPage', () {
    testWidgets('shows the streak, the crowns and the badges', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ProfileTabPage inputPage = ProfileTabPage(
        profileId: 'p-1',
        useCases: buildTabUseCases(
          rewards: FixedRewardService(streak: 6, badges: <String>{'a', 'b'}),
          crowns: FixedCrownService(crowns: 1),
        ),
        sections: const <Widget>[Text('Mes tables')],
      );
      // Act
      await pumpLocalized(tester, Scaffold(body: inputPage));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('6 jours'), findsOneWidget);
      expect(find.text('de série'), findsOneWidget);
      expect(find.text('couronne'), findsOneWidget);
      expect(find.text('badges'), findsOneWidget);
      expect(find.text('Mes tables'), findsOneWidget);
    });
  });
}

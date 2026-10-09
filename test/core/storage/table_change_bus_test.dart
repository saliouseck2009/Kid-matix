import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';

void main() {
  group('TableChangeBus', () {
    late TableChangeBus bus;
    setUp(() {
      bus = TableChangeBus();
    });
    tearDown(() async {
      await bus.dispose();
    });
    test('a watcher is told when its table changes', () async {
      // Arrange
      const String inputTable = 'profile';
      final Future<String> actualEvent = bus
          .watchTable(table: inputTable)
          .first;
      // Act
      bus.notifyChanged(table: inputTable);
      // Assert
      expect(await actualEvent, inputTable);
    });
    test('a watcher ignores the changes of other tables', () async {
      // Arrange
      const String inputWatchedTable = 'profile';
      const String inputOtherTable = 'quiz_session';
      final List<String> actualEvents = <String>[];
      bus.watchTable(table: inputWatchedTable).listen(actualEvents.add);
      // Act
      bus.notifyChanged(table: inputOtherTable);
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(actualEvents, isEmpty);
    });
  });
}

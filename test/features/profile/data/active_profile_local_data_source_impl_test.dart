import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source_impl.dart';

import '../../../helpers/in_memory_local_storage.dart';

void main() {
  late InMemoryLocalStorage storage;
  late ActiveProfileLocalDataSourceImpl dataSource;

  setUp(() {
    storage = InMemoryLocalStorage();
    dataSource = ActiveProfileLocalDataSourceImpl(storage: storage);
  });

  group('ActiveProfileLocalDataSourceImpl', () {
    test('has no active player at first', () async {
      // Act
      final String? actualProfileId = await dataSource.readActiveProfileId();
      // Assert
      expect(actualProfileId, isNull);
    });
    test('remembers the active player', () async {
      // Arrange
      const String expectedProfileId = 'profile-1';
      // Act
      await dataSource.writeActiveProfileId(profileId: expectedProfileId);
      // Assert
      final String? actualProfileId = await dataSource.readActiveProfileId();
      expect(actualProfileId, expectedProfileId);
    });
    test('forgets the active player', () async {
      // Arrange
      await dataSource.writeActiveProfileId(profileId: 'profile-1');
      // Act
      await dataSource.clearActiveProfileId();
      // Assert
      final String? actualProfileId = await dataSource.readActiveProfileId();
      expect(actualProfileId, isNull);
    });
  });
}

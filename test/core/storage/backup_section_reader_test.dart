import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';

final class _CountingIds implements IdGenerator {
  int _count = 0;

  @override
  String generateId() => 'new-${++_count}';
}

int _readCount(Map<String, Object?> row) => row['count']! as int;

enum _Color { red }

_Color _readColor(Map<String, Object?> row) =>
    _Color.values.byName(row['color']! as String);

void main() {
  group('BackupSectionReader', () {
    test('reads rows and ignores unknown keys', () {
      // Arrange
      const Map<String, Object?> inputContent = <String, Object?>{
        'rows': <Object?>[
          <String, Object?>{'count': 1, 'unknown': 'x'},
          <String, Object?>{'count': 2},
        ],
      };
      // Act
      final List<int> actualRows = BackupSectionReader.readRows(
        inputContent,
        key: 'rows',
        fromJson: _readCount,
      );
      // Assert
      expect(actualRows, <int>[1, 2]);
    });

    test('reads a missing key as empty', () {
      // Act
      final List<int> actualRows = BackupSectionReader.readRows(
        const <String, Object?>{},
        key: 'rows',
        fromJson: _readCount,
      );
      final int? actualRow = BackupSectionReader.readRow(
        const <String, Object?>{},
        key: 'row',
        fromJson: _readCount,
      );
      final String? actualText = BackupSectionReader.readText(
        const <String, Object?>{},
        key: 'text',
      );
      // Assert
      expect(actualRows, isEmpty);
      expect(actualRow, isNull);
      expect(actualText, isNull);
    });

    test('refuses malformed content with a FormatException', () {
      // Arrange
      final List<void Function()> inputReads = <void Function()>[
        () => BackupSectionReader.readRows(
          const <String, Object?>{'rows': 'nope'},
          key: 'rows',
          fromJson: _readCount,
        ),
        () => BackupSectionReader.readRows(
          const <String, Object?>{
            'rows': <Object?>[1],
          },
          key: 'rows',
          fromJson: _readCount,
        ),
        () => BackupSectionReader.readRow(
          const <String, Object?>{
            'row': <String, Object?>{'count': 'one'},
          },
          key: 'row',
          fromJson: _readCount,
        ),
        () => BackupSectionReader.readRow(
          const <String, Object?>{
            'row': <String, Object?>{'color': 'blue'},
          },
          key: 'row',
          fromJson: _readColor,
        ),
        () => BackupSectionReader.readText(
          const <String, Object?>{'text': 3},
          key: 'text',
        ),
      ];
      // Act and assert
      for (final void Function() read in inputReads) {
        expect(read, throwsFormatException);
      }
    });
  });

  group('BackupIdMap', () {
    test('gives each identifier of the file one new identifier', () {
      // Arrange
      final BackupIdMap inputIds = BackupIdMap(
        profileId: 'player',
        idGenerator: _CountingIds(),
      );
      // Act
      final List<String> actualIds = <String>[
        inputIds.remap('s1'),
        inputIds.remap('s2'),
        inputIds.remap('s1'),
      ];
      // Assert
      expect(actualIds, <String>['new-1', 'new-2', 'new-1']);
      expect(inputIds.profileId, 'player');
    });
  });
}

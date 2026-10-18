import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_codec.dart';
import 'package:kid_matix/features/profile/data/models/profile_backup_file_model.dart';

const ProfileBackupFileModel _file = ProfileBackupFileModel(
  format: 'kidmatix-profile',
  version: 1,
  exportedAt: '2026-10-12T16:00:00.000Z',
  appVersion: '1.2.0',
  sections: <String, Object?>{
    'profile': <String, Object?>{'profile': null},
  },
);

String _text(Map<String, Object?> changes) {
  return jsonEncode(<String, Object?>{..._file.toJson(), ...changes});
}

void main() {
  const ProfileBackupCodec codec = ProfileBackupCodec();

  group('ProfileBackupCodec', () {
    test('reads back the file it writes', () {
      // Act
      final ProfileBackupFileModel actualFile = codec.decode(
        codec.encode(_file),
      );
      // Assert
      expect(actualFile.toJson(), _file.toJson());
    });

    test('ignores keys it does not know', () {
      // Act
      final ProfileBackupFileModel actualFile = codec.decode(
        _text(<String, Object?>{'comment': 'later'}),
      );
      // Assert
      expect(actualFile.version, 1);
    });

    test('refuses what is no backup or is damaged', () {
      // Arrange
      final List<String> inputTexts = <String>[
        'not json',
        '[1, 2]',
        _text(<String, Object?>{'format': 'other'}),
        _text(<String, Object?>{'format': 3}),
        _text(<String, Object?>{'version': null}),
        _text(<String, Object?>{'version': 0}),
        _text(<String, Object?>{'version': '1'}),
        _text(<String, Object?>{'sections': 'none'}),
        _text(<String, Object?>{'exportedAt': 'yesterday'}),
      ];
      // Act and assert
      for (final String text in inputTexts) {
        expect(
          () => codec.decode(text),
          throwsA(isA<InvalidFileException>()),
          reason: text,
        );
      }
    });

    test('refuses a newer version before reading the rest', () {
      // Act and assert
      expect(
        () => codec.decode(
          _text(<String, Object?>{'version': 3, 'sections': 7}),
        ),
        throwsA(isA<UnsupportedVersionException>()),
      );
    });
  });
}

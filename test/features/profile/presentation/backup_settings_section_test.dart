import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/widgets/parental_gate.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_params.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

const int _seed = 42;

final ProfileBackupEntity _backup = ProfileBackupEntity(
  nickname: 'Awa',
  level: 5,
  exportedAt: DateTime.utc(2026, 10, 12),
  sections: const <String, Object?>{},
);

void main() {
  late MockExportProfileUseCase mockExport;
  late MockPickBackupUseCase mockPick;
  late MockImportBackupUseCase mockImport;

  setUpAll(() {
    registerFallbackValue(
      ImportBackupParams(backup: _backup, choice: const ImportAsNewPlayer()),
    );
  });

  setUp(() {
    mockExport = MockExportProfileUseCase();
    mockPick = MockPickBackupUseCase();
    mockImport = MockImportBackupUseCase();
    when(
      () => mockExport.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<bool>(true));
    when(() => mockPick.call()).thenAnswer(
      (_) async => DataSuccess<BackupPreviewEntity?>(
        BackupPreviewEntity(
          backup: _backup,
          conflictingProfile: buildProfile(id: 'profile-1'),
        ),
      ),
    );
    when(
      () => mockImport.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<String>('Awa'));
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpLocalized(
      tester,
      buildProfilePages(
        backupUseCases: buildBackupUseCases(
          exportProfile: mockExport,
          pickBackup: mockPick,
          importBackup: mockImport,
        ),
        gateRandom: Random(_seed),
      ).buildSettingsPage(profileId: 'profile-1', onBack: () {}),
    );
    await tester.pumpAndSettle();
  }

  /// Taps [row], then answers the parental gate, rightly unless [isWrong].
  Future<void> openThroughGate(
    WidgetTester tester,
    String row, {
    bool isWrong = false,
  }) async {
    await tester.ensureVisible(find.text(row));
    await tester.pumpAndSettle();
    await tester.tap(find.text(row));
    await tester.pumpAndSettle();
    final int number =
        ParentalGate.minNumber +
        Random(
          _seed,
        ).nextInt(ParentalGate.maxNumber - ParentalGate.minNumber + 1);
    await tester.enterText(
      find.descendant(
        of: find.byType(ParentalGate),
        matching: find.byType(TextField),
      ),
      '${isWrong ? number + 1 : number}',
    );
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
  }

  BackupImportChoice importedChoice() {
    return (verify(
              () => mockImport.call(params: captureAny(named: 'params')),
            ).captured.last
            as ImportBackupParams)
        .choice;
  }

  group('BackupSettingsSection', () {
    testWidgets('shows the backup section of mockup 13', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpSettings(tester);
      await tester.ensureVisible(find.text('Importer un profil'));
      // Assert
      expect(find.text('Sauvegarde'), findsOneWidget);
      expect(find.text('Exporter mon profil'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
    });

    testWidgets('exports once an adult typed the number', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await openThroughGate(tester, 'Exporter mon profil');
      // Assert
      verify(() => mockExport.call(params: 'profile-1')).called(1);
      expect(find.textContaining('Fichier prêt'), findsOneWidget);
    });

    testWidgets('does not export after a wrong answer', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await openThroughGate(tester, 'Exporter mon profil', isWrong: true);
      // Assert
      verifyNever(() => mockExport.call(params: any(named: 'params')));
      expect(find.byType(ParentalGate), findsNothing);
    });

    testWidgets('replaces the player with the same nickname', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await openThroughGate(tester, 'Importer un profil');
      expect(find.text('Awa existe déjà'), findsOneWidget);
      expect(find.textContaining('au niveau 5'), findsOneWidget);
      await tester.tap(find.text('Remplacer'));
      await tester.pumpAndSettle();
      // Assert
      expect(importedChoice(), const ReplacePlayer(profileId: 'profile-1'));
      expect(
        find.textContaining('Progression de Awa restaurée'),
        findsOneWidget,
      );
    });

    testWidgets('asks another nickname until one is free', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockImport.call(
          params: ImportBackupParams(
            backup: _backup,
            choice: const RenamePlayer(nickname: 'Lina'),
          ),
        ),
      ).thenAnswer((_) async => const DataFailed<String>(ConflictException()));
      when(
        () => mockImport.call(
          params: ImportBackupParams(
            backup: _backup,
            choice: const RenamePlayer(nickname: 'Lou'),
          ),
        ),
      ).thenAnswer((_) async => const DataSuccess<String>('Lou'));
      await pumpSettings(tester);
      await openThroughGate(tester, 'Importer un profil');
      // Act
      await tester.tap(find.text('Renommer'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Lina');
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      final Finder actualRetry = find.text('Nouveau pseudo');
      final bool isRetryShown = tester.any(actualRetry);
      final bool isTakenShown = tester.any(
        find.text('Ce nom est déjà pris sur ce téléphone.'),
      );
      await tester.enterText(find.byType(TextFormField), 'Lou');
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      // Assert
      expect(isRetryShown, isTrue);
      expect(isTakenShown, isTrue);
      expect(importedChoice(), const RenamePlayer(nickname: 'Lou'));
      expect(find.textContaining('Profil de Lou importé'), findsOneWidget);
    });

    testWidgets('gives up the import on cancel', (WidgetTester tester) async {
      // Arrange
      await pumpSettings(tester);
      await openThroughGate(tester, 'Importer un profil');
      // Act
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      // Assert
      verifyNever(() => mockImport.call(params: any(named: 'params')));
      expect(find.text('Awa existe déjà'), findsNothing);
    });

    testWidgets('says when the file is damaged or too new', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockPick.call()).thenAnswer(
        (_) async =>
            const DataFailed<BackupPreviewEntity?>(InvalidFileException()),
      );
      await pumpSettings(tester);
      // Act
      await openThroughGate(tester, 'Importer un profil');
      // Assert
      expect(
        find.text(
          "Ce fichier n'est pas une sauvegarde Kid Matix, ou il est abîmé.",
        ),
        findsOneWidget,
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/usecases/confirm_results_qr_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/make_results_qr_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/receive_results_qr_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/results_qr_pages.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/camera_qr_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../helpers/pump_localized.dart';

final class _MockMake extends Mock implements MakeResultsQrUseCase {}

final class _MockConfirm extends Mock implements ConfirmResultsQrUseCase {}

final class _MockReceive extends Mock implements ReceiveResultsQrUseCase {}

void main() {
  late _MockMake make;
  late _MockConfirm confirm;
  late _MockReceive receive;
  late ResultsQrPages pages;

  setUpAll(() {
    registerFallbackValue((classroomId: '', sequence: 0));
  });

  setUp(() {
    make = _MockMake();
    confirm = _MockConfirm();
    receive = _MockReceive();
    pages = ResultsQrPages(
      useCases: (make: make, confirm: confirm, receive: receive),
      // The camera of the test reads one code when tapped.
      scanner: (BuildContext context, ValueChanged<String> onRead) =>
          TextButton(
            onPressed: () => onRead('KMXQ1.x'),
            child: const Text('📷'),
          ),
    );
  });

  testWidgets('shows the code, then remembers it was read', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => make(params: 'c1')).thenAnswer(
      (_) async => const DataSuccess<ResultsQr>((
        text: 'KMXQ1.abc',
        sequence: 7,
        sessionCount: 3,
      )),
    );
    when(
      () => confirm(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    await pumpLocalized(
      tester,
      pages.buildSendPage(classroomId: 'c1', onBack: () {}),
    );
    await tester.pump();
    // Act
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('3 nouvelles séances'), findsOneWidget);
    await tester.ensureVisible(find.text("C'est reçu"));
    await tester.tap(find.text("C'est reçu"));
    await tester.pump();
    // Assert
    verify(
      () => confirm(params: (classroomId: 'c1', sequence: 7)),
    ).called(1);
    expect(find.text('Ces résultats ne seront plus renvoyés.'), findsOneWidget);
  });

  testWidgets('sends to the file when the results are too many', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => make(params: 'c1')).thenAnswer(
      (_) async => const DataFailed<ResultsQr>(
        LimitReachedException(message: 'Too big'),
      ),
    );
    // Act
    await pumpLocalized(
      tester,
      pages.buildSendPage(classroomId: 'c1', onBack: () {}),
    );
    await tester.pump();
    // Assert
    expect(find.byType(QrImageView), findsNothing);
    expect(find.textContaining('envoie plutôt le fichier'), findsOneWidget);
  });

  testWidgets('merges the code the camera reads', (WidgetTester tester) async {
    // Arrange
    when(() => receive(params: 'KMXQ1.x')).thenAnswer(
      (_) async => const DataSuccess<ClassroomMergeReport>(
        ClassroomMergeReport(
          classroomName: 'CE1',
          addedPupilCount: 0,
          addedSessionCount: 2,
        ),
      ),
    );
    await pumpLocalized(tester, pages.buildReceivePage(onBack: () {}));
    // Act
    await tester.tap(find.text('📷'));
    await tester.pump();
    // Assert
    expect(find.textContaining('2 nouvelles séances'), findsOneWidget);
    expect(find.text('Lire un autre code'), findsOneWidget);
  });

  for (final (MobileScannerErrorCode code, String expected)
      in <
        (
          MobileScannerErrorCode,
          String,
        )
      >[
        (MobileScannerErrorCode.permissionDenied, 'Réglages de la tablette'),
        (MobileScannerErrorCode.unsupported, "n'a pas de caméra"),
        (MobileScannerErrorCode.genericError, "n'est pas disponible"),
      ]) {
    testWidgets('says what to do when the camera fails: ${code.name}', (
      WidgetTester tester,
    ) async {
      // Arrange: a camera that fails as mobile_scanner reports it.
      final ResultsQrPages inputPages = ResultsQrPages(
        useCases: (make: make, confirm: confirm, receive: receive),
        scanner: (BuildContext context, ValueChanged<String> onRead) =>
            QrCameraErrorView(errorCode: code),
      );
      // Act
      await pumpLocalized(tester, inputPages.buildReceivePage(onBack: () {}));
      // Assert
      expect(find.textContaining(expected), findsOneWidget);
    });
  }
}

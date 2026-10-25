import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/repositories/report_share_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/share_files_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/report_export_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/report_export_card.dart';

import '../../../helpers/pump_localized.dart';

/// A share sheet that keeps each share.
final class _RecordingShare implements ReportShareRepository {
  final List<List<String>> shares = <List<String>>[];

  @override
  Future<DataState<bool>> share({required List<SharedFile> files}) async {
    shares.add(files.map((SharedFile file) => file.name).toList());
    return const DataSuccess<bool>(true);
  }

  @override
  Future<DataState<List<int>?>> pick() async =>
      const DataSuccess<List<int>?>(null);
}

void main() {
  testWidgets('shares one version at a time, the anonymous one by default', (
    WidgetTester tester,
  ) async {
    // Arrange
    final _RecordingShare share = _RecordingShare();
    final List<AssessmentPeriod> periods = <AssessmentPeriod>[
      AssessmentPeriod(
        key: 'debut',
        label: 'Début',
        startedAt: DateTime(2026, 10),
        assessmentIds: const <String>['a1'],
      ),
    ];
    await pumpLocalized(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<ReportExportCubit<String>>(
            create: (_) => ReportExportCubit<String>(
              periods: periods,
              source: ({String? fromKey, required String toKey}) async =>
                  const DataSuccess<String>('report'),
              share: ShareFilesUseCase(repository: share),
            ),
            child: ReportExportCard<String>(
              title: 'Rapport',
              hint: 'Indice',
              periods: periods,
              hasNamedVersion: true,
              rendererOf:
                  (BuildContext context, ReportFileKind kind, bool isNamed) =>
                      (String report) async => <SharedFile>[
                        SharedFile(
                          name: isNamed ? 'named' : 'anonymous',
                          bytes: const <int>[],
                          mimeType: SharedFile.pdfType,
                        ),
                      ],
            ),
          ),
        ),
      ),
    );
    // Act
    await tester.tap(find.text('Exporter en PDF'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Version nominative (pour moi)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exporter en PDF'));
    await tester.pumpAndSettle();
    // Assert
    expect(share.shares, <List<String>>[
      <String>['anonymous'],
      <String>['named'],
    ]);
  });
}

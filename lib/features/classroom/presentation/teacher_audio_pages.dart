import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_recordings_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_recordings_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/recording_lifecycle_guard.dart';

/// Builds « Enregistrer les explications » (F31-06), in the teacher area.
final class TeacherAudioPages {
  /// Creates the factory.
  const TeacherAudioPages({
    required this._useCases,
    required this._domains,
    required this._ticker,
  });

  final TeacherRecordingUseCases _useCases;
  final DomainRegistry _domains;
  final Ticker _ticker;

  /// The button of « Mes classes ».
  Widget buildOpenButton({required VoidCallback onOpen}) {
    return Builder(
      builder: (BuildContext context) => DepthButton(
        label: context.l10n.classroomRecordingsOpen,
        icon: Icons.mic_rounded,
        variant: DepthButtonVariant.secondary,
        onPressed: onOpen,
      ),
    );
  }

  /// The page of the recordings.
  Widget buildPage({required VoidCallback onBack}) {
    return BlocProvider<TeacherRecordingsCubit>(
      create: (_) =>
          TeacherRecordingsCubit(useCases: _useCases, ticker: _ticker)..load(),
      child: RecordingLifecycleGuard(
        child: TeacherRecordingsPage(
          labels: ClassItemLabels(domains: _domains),
          onBack: onBack,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/provisional_audio_notice.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_recordings.dart';
import 'package:kid_matix/features/classroom/domain/usecases/record_explanation_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_recordings_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_recordings_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/recording_banner.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/recording_word_tile.dart';

/// « Enregistrer les explications »: the teacher records their own
/// explanation of each math word in the help language; the microphone
/// is asked here, in the teacher area only. No mockup: built with the
/// design system (F31).
class TeacherRecordingsPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const TeacherRecordingsPage({
    required this.labels,
    required this.onBack,
    super.key,
  });

  /// Writes the words.
  final ClassItemLabels labels;

  /// Goes back to « Mes classes ».
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<TeacherRecordingsCubit, TeacherRecordingsState>(
            listenWhen: (
              TeacherRecordingsState before,
              TeacherRecordingsState after,
            ) => after.notice != null || after.errorCode != null,
            listener: _showNotice,
            builder: (BuildContext context, TeacherRecordingsState state) {
              final TeacherRecordings? page = state.page;
              if (page == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return _RecordingsView(
                page: page,
                state: state,
                labels: labels,
                onBack: onBack,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, TeacherRecordingsState state) {
    final String message = switch ((state.notice, state.errorCode)) {
      (RecordingNotice.saved, _) => context.l10n.classroomRecordingsSaved,
      (RecordingNotice.exported, _) => context.l10n.classroomRecordingsExported,
      (RecordingNotice.imported, _) => context.l10n.classroomRecordingsImported(
        state.importedCount,
      ),
      (_, AppErrorCode.permissionDenied) =>
        context.l10n.classroomRecordingsDenied,
      (_, AppErrorCode.invalidFile) => context.l10n.classroomRecordingsInvalid,
      (_, AppErrorCode.notFound) => context.l10n.classroomRecordingsNothing,
      (_, AppErrorCode.fileTooBig) => context.l10n.classroomImportTooBig,
      _ => context.l10n.classroomErrorGeneric,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RecordingsView extends StatelessWidget {
  const _RecordingsView({
    required this.page,
    required this.state,
    required this.labels,
    required this.onBack,
  });

  final TeacherRecordings page;
  final TeacherRecordingsState state;
  final ClassItemLabels labels;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final TeacherRecordingsCubit cubit = context.read<TeacherRecordingsCubit>();
    final String? recording = state.recordingWordKey;
    final bool isFree = recording == null && !state.isBusy;
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(AppSizes.space24),
          sliver: SliverToBoxAdapter(
            child: _RecordingsHeader(page: page, onBack: onBack),
          ),
        ),
        if (recording != null)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
            sliver: SliverToBoxAdapter(
              child: RecordingBanner(
                word: labels.describe(
                  page.words
                      .firstWhere((RecordingWord w) => w.wordKey == recording)
                      .itemKey,
                ),
                seconds: state.recordedSeconds,
                maxSeconds: RecordExplanationUseCase.maxLength.inSeconds,
                onKeep: cubit.keep,
                onCancel: cubit.cancel,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
          sliver: SliverList.builder(
            itemCount: page.words.length,
            itemBuilder: (BuildContext context, int index) {
              final RecordingWord word = page.words[index];
              return RecordingWordTile(
                key: ValueKey<String>(word.itemKey),
                word: word,
                label: labels.describe(word.itemKey),
                isEnabled: isFree,
                onRecord: () => cubit.start(word.wordKey),
                onListen: () => cubit.play(word.wordKey),
                onDelete: () => cubit.delete(word.wordKey),
              );
            },
          ),
        ),
        if (page.languageCode != null)
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.space24),
            sliver: SliverToBoxAdapter(
              child: _PackButtons(isEnabled: isFree),
            ),
          ),
      ],
    );
  }
}

class _RecordingsHeader extends StatelessWidget {
  const _RecordingsHeader({required this.page, required this.onBack});

  final TeacherRecordings page;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final TeacherRecordingsCubit cubit = context.read<TeacherRecordingsCubit>();
    final String? language = page.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        ClassroomPageHeader(
          title: context.l10n.classroomRecordingsOpen,
          subtitle: language == null
              ? null
              : context.l10n.helpAudioLanguageName(language),
          onBack: onBack,
        ),
        Text(context.l10n.classroomRecordingsHint),
        if (page.isProvisional) const ProvisionalAudioNotice(),
        if (language == null) Text(context.l10n.classroomRecordingsNoPack),
        if (page.languages.length > 1)
          DropdownButtonFormField<String>(
            initialValue: language,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.classroomRecordingsLanguage,
            ),
            items: <DropdownMenuItem<String>>[
              for (final String code in page.languages)
                DropdownMenuItem<String>(
                  value: code,
                  child: Text(context.l10n.helpAudioLanguageName(code)),
                ),
            ],
            onChanged: (String? code) =>
                cubit.load(languageCode: code, kind: page.kind),
          ),
        if (language != null)
          SegmentedButton<WordAudioKind>(
            segments: <ButtonSegment<WordAudioKind>>[
              ButtonSegment<WordAudioKind>(
                value: WordAudioKind.explanation,
                label: Text(context.l10n.classroomRecordingsExplanation),
              ),
              ButtonSegment<WordAudioKind>(
                value: WordAudioKind.example,
                label: Text(context.l10n.classroomRecordingsExample),
              ),
            ],
            selected: <WordAudioKind>{page.kind},
            onSelectionChanged: (Set<WordAudioKind> kinds) =>
                cubit.load(languageCode: language, kind: kinds.single),
          ),
      ],
    );
  }
}

class _PackButtons extends StatelessWidget {
  const _PackButtons({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final TeacherRecordingsCubit cubit = context.read<TeacherRecordingsCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        DepthButton(
          label: context.l10n.classroomRecordingsExport,
          icon: Icons.ios_share_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: isEnabled ? cubit.exportPack : null,
        ),
        DepthButton(
          label: context.l10n.classroomRecordingsImport,
          icon: Icons.download_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: isEnabled ? cubit.importPack : null,
        ),
      ],
    );
  }
}

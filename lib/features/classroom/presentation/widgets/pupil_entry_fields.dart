import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_state.dart';

/// The pupils part of the form of a class: nicknames, one per line, or a
/// number of numbered pupils, with the advice against real names and the
/// summary of who will be added.
class PupilEntryFields extends StatelessWidget {
  /// Creates the fields of [state].
  const PupilEntryFields({required this.state, super.key});

  static const int _listLines = 8;
  static const int _countDigits = 2;

  /// The form.
  final ClassroomFormState state;

  @override
  Widget build(BuildContext context) {
    final ClassroomFormCubit cubit = context.read<ClassroomFormCubit>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> nicknames = state.nicknames;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        Text(context.l10n.classroomPupilsTitle, style: textTheme.titleLarge),
        ChoiceSegments<PupilEntryMode>(
          choices: PupilEntryMode.values,
          selected: state.mode,
          labelOf: (PupilEntryMode mode) => switch (mode) {
            PupilEntryMode.list => context.l10n.classroomPupilsByList,
            PupilEntryMode.numbers => context.l10n.classroomPupilsByNumber,
          },
          onSelected: cubit.changeMode,
        ),
        if (state.mode == PupilEntryMode.list)
          TextField(
            key: const ValueKey<String>('pupil-list'),
            minLines: _listLines,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: context.l10n.classroomPupilsListLabel,
              alignLabelWithHint: true,
            ),
            onChanged: cubit.changeList,
          )
        else
          TextField(
            key: const ValueKey<String>('pupil-count'),
            maxLength: _countDigits,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.none,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: context.l10n.classroomPupilsCountLabel,
            ),
            onChanged: cubit.changeNumberCount,
          ),
        Text(
          context.l10n.classroomPupilsPrivacyHint,
          style: textTheme.bodySmall?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
        Text(
          context.l10n.classroomPupilsPreview(
            nicknames.length,
            nicknames.firstOrNull ?? '',
            nicknames.lastOrNull ?? '',
          ),
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

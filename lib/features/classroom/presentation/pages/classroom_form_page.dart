import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_messages.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_entry_fields.dart';

/// Creates a class and all its pupils in one go, or adds pupils to a
/// class: a list of nicknames or a number of numbered pupils. No mockup:
/// built with the design system (F29-11).
class ClassroomFormPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const ClassroomFormPage({
    required this.onBack,
    required this.onSaved,
    super.key,
  });

  /// Goes back without saving.
  final VoidCallback onBack;

  /// Opens the class once saved.
  final ValueChanged<String> onSaved;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<ClassroomFormCubit, ClassroomFormState>(
            listenWhen: (
              ClassroomFormState previous,
              ClassroomFormState next,
            ) => next.savedClassroomId != null,
            listener: (BuildContext context, ClassroomFormState state) =>
                onSaved(state.savedClassroomId!),
            builder: (BuildContext context, ClassroomFormState state) {
              return _FormView(state: state, onBack: onBack);
            },
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({required this.state, required this.onBack});

  final ClassroomFormState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ClassroomFormCubit cubit = context.read<ClassroomFormCubit>();
    final String title = state.isAddition
        ? context.l10n.classroomAddPupils
        : context.l10n.classroomNew;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: <Widget>[
        ClassroomPageHeader(title: title, onBack: onBack),
        const SizedBox(height: AppSizes.space24),
        if (!state.isAddition) ...<Widget>[
          TextField(
            maxLength: ClassroomRules.maxNameLength,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: context.l10n.classroomNameLabel,
              hintText: context.l10n.classroomNameHint,
            ),
            onChanged: cubit.changeName,
          ),
          const SizedBox(height: AppSizes.space16),
        ],
        PupilEntryFields(state: state),
        if (state.problem case final ClassroomFormProblem problem)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.space12),
              child: Text(
                context.l10n.classroomFormProblem(
                  problem,
                  unusable: state.unusable,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSizes.space24),
        DepthButton(
          label: state.isAddition
              ? context.l10n.classroomAddPupils
              : context.l10n.classroomCreate,
          onPressed: state.isSaving ? null : cubit.submit,
        ),
      ],
    );
  }
}

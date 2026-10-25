import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/parental_gate.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_messages.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';

/// The door of the teacher area: the first visit chooses a 4-digit code
/// and types it twice, later visits type it. No mockup: built with the
/// design system (F29-11).
class TeacherAccessPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const TeacherAccessPage({required this.onBack, super.key});

  /// Goes back to « Qui joue ? ».
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<TeacherAccessCubit, TeacherAccessState>(
            builder: (BuildContext context, TeacherAccessState state) {
              return switch (state) {
                TeacherAccessLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                TeacherAccessFailure() => Center(
                  child: Text(context.l10n.classroomErrorGeneric),
                ),
                TeacherAccessReady() => _CodeForm(
                  key: ValueKey<TeacherCodeStep>(state.step),
                  state: state,
                  onBack: onBack,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _CodeForm extends StatefulWidget {
  const _CodeForm({required this.state, required this.onBack, super.key});

  final TeacherAccessReady state;
  final VoidCallback onBack;

  @override
  State<_CodeForm> createState() => _CodeFormState();
}

class _CodeFormState extends State<_CodeForm> {
  static const double _lockSize = 64;

  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final String code = _code.text;
    _code.clear();
    context.read<TeacherAccessCubit>().submit(code);
  }

  // An adult answers the gate of the backups (F20) before a new code.
  Future<void> _forget() async {
    final TeacherAccessCubit cubit = context.read<TeacherAccessCubit>();
    if (await askAnAdult(context)) await cubit.forgetCode();
  }

  @override
  Widget build(BuildContext context) {
    final TeacherAccessReady state = widget.state;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: <Widget>[
        ClassroomPageHeader(
          title: context.l10n.classroomTeacherArea,
          onBack: widget.onBack,
        ),
        const SizedBox(height: AppSizes.space24),
        Icon(
          Icons.lock_rounded,
          size: _lockSize,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSizes.space16),
        Text(
          context.l10n.teacherCodeHint(state.step),
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSizes.space16),
        TextField(
          controller: _code,
          autofocus: true,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          maxLength: ClassroomRules.teacherCodeLength,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.none,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: context.l10n.classroomCodeLabel,
          ),
          onSubmitted: (_) => _submit(),
        ),
        if (state.error case final TeacherCodeError error)
          Semantics(
            liveRegion: true,
            child: Text(
              context.l10n.teacherCodeError(error),
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: AppSizes.space24),
        DepthButton(
          label: state.step == TeacherCodeStep.enter
              ? context.l10n.classroomCodeOpen
              : context.l10n.classroomCodeNext,
          onPressed: state.isBusy ? null : _submit,
        ),
        if (state.step == TeacherCodeStep.enter)
          TextButton(
            onPressed: _forget,
            child: Text(context.l10n.classroomCodeForgotten),
          ),
      ],
    );
  }
}

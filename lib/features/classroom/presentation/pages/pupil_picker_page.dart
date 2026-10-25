import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_avatar_builder.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_grid.dart';

/// « Qui es-tu ? »: a pupil finds their name or avatar in their class,
/// with a search for a big class, and starts playing. No mockup: built
/// with the design system (F29-11).
class PupilPickerPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const PupilPickerPage({
    required this.avatarOf,
    required this.onBack,
    this.header,
    super.key,
  });

  /// Draws the avatars.
  final PupilAvatarBuilder avatarOf;

  /// Goes back to « Qui joue ? ».
  final VoidCallback onBack;

  /// Shown above the search, such as the gauge of the class challenge,
  /// or `null`.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ClassroomRosterCubit, ClassroomRosterState>(
            builder: (BuildContext context, ClassroomRosterState state) {
              return switch (state) {
                ClassroomRosterLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ClassroomRosterFailure() => Center(
                  child: Text(context.l10n.classroomErrorGeneric),
                ),
                ClassroomRosterLoaded() => _PickerView(
                  state: state,
                  avatarOf: avatarOf,
                  onBack: onBack,
                  header: header,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _PickerView extends StatelessWidget {
  const _PickerView({
    required this.state,
    required this.avatarOf,
    required this.onBack,
    required this.header,
  });

  final ClassroomRosterLoaded state;
  final PupilAvatarBuilder avatarOf;
  final VoidCallback onBack;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final ClassroomRosterCubit cubit = context.read<ClassroomRosterCubit>();
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(AppSizes.space24),
          sliver: SliverList.list(
            children: <Widget>[
              ClassroomPageHeader(
                title: context.l10n.classroomPickerTitle,
                subtitle: state.roster.classroom.name,
                onBack: onBack,
              ),
              if (header case final Widget above) ...<Widget>[
                const SizedBox(height: AppSizes.space16),
                above,
              ],
              const SizedBox(height: AppSizes.space16),
              TextField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  hintText: context.l10n.classroomPickerSearch,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
                onChanged: cubit.search,
              ),
            ],
          ),
        ),
        PupilGrid(
          pupils: state.visiblePupils,
          avatarOf: avatarOf,
          emptyText: state.roster.pupils.isEmpty
              ? context.l10n.classroomPickerEmpty
              : context.l10n.classroomPickerNoMatch,
          onTap: cubit.selectPupil,
        ),
      ],
    );
  }
}

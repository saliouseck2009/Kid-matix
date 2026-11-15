import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_progress_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/path_overview_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/path_overview_state.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_progress_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';

/// Opens « Mes parcours » over the screen of [context], whose
/// `DomainChoiceCubit` and `PathOverviewCubit` it uses; the progress is
/// read again each time.
Future<void> showPathPicker(BuildContext context) async {
  final DomainChoiceCubit choice = context.read<DomainChoiceCubit>();
  final PathOverviewCubit overview = context.read<PathOverviewCubit>();
  unawaited(overview.load());
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(PathPickerSheet.radius),
      ),
    ),
    builder: (BuildContext context) => MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<DomainChoiceCubit>.value(value: choice),
        BlocProvider<PathOverviewCubit>.value(value: overview),
      ],
      child: const PathPickerSheet(),
    ),
  );
}

/// « Mes parcours »: every domain of the app with the player's progress;
/// tapping one makes it the domain of the map and closes the sheet.
class PathPickerSheet extends StatelessWidget {
  /// Creates the sheet.
  const PathPickerSheet({super.key});

  /// Corner radius of the top of the sheet.
  static const double radius = 28;

  /// Width of the drag handle.
  static const double handleWidth = 44;

  /// Height of the drag handle.
  static const double handleHeight = 5;

  /// Gap between two cards.
  static const double cardGap = 10;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space16,
          AppSizes.space8,
          AppSizes.space16,
          AppSizes.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSizes.space12,
          children: <Widget>[
            Center(
              child: Container(
                width: handleWidth,
                height: handleHeight,
                decoration: BoxDecoration(
                  color: context.palette.softBorder,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSizes.space8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            context.l10n.pathPickerTitle,
                            style: textTheme.headlineMedium,
                          ),
                        ),
                        Text(
                          context.l10n.pathPickerHint,
                          style: textTheme.bodyMedium?.copyWith(
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: context.l10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Flexible(child: _PathPickerBody()),
          ],
        ),
      ),
    );
  }
}

/// The cards of the domains, or the wait, or the error.
class _PathPickerBody extends StatelessWidget {
  const _PathPickerBody();

  @override
  Widget build(BuildContext context) {
    final DomainChoiceState choice = context.watch<DomainChoiceCubit>().state;
    if (choice is! DomainChoiceLoaded) return const SizedBox.shrink();
    final String selectedId = choice.choice.selectedId;
    return BlocBuilder<PathOverviewCubit, PathOverviewState>(
      builder: (BuildContext context, PathOverviewState state) {
        switch (state) {
          case PathOverviewLoading():
            return const Padding(
              padding: EdgeInsets.all(AppSizes.space24),
              child: Center(child: CircularProgressIndicator()),
            );
          case PathOverviewFailure(:final errorCode):
            return Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Text(
                PathLabels(
                  domainId: selectedId,
                  l10n: context.l10n,
                ).describeError(errorCode),
                textAlign: TextAlign.center,
              ),
            );
          case PathOverviewLoaded(:final overview):
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: PathPickerSheet.cardGap,
                children: <Widget>[
                  for (final DomainProgressEntity progress in overview.domains)
                    DomainProgressCard(
                      progress: progress,
                      isCurrent: progress.domainId == selectedId,
                      isRecommended:
                          progress.domainId == overview.recommendedDomainId,
                      onTap: () => _choose(context, progress.domainId),
                    ),
                ],
              ),
            );
        }
      },
    );
  }

  void _choose(BuildContext context, String domainId) {
    unawaited(context.read<DomainChoiceCubit>().select(domainId));
    Navigator.of(context).pop();
  }
}

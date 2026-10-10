import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';

/// Temporary home tab that starts a quiz on the table of 5.
///
/// Lot F3 needs a way to play before the learning path exists; lot F5
/// replaces this page with the map of the tables.
class ProvisionalQuizLauncherPage extends StatelessWidget {
  /// Creates the page; [onStart] opens the quiz.
  const ProvisionalQuizLauncherPage({required this.onStart, super.key});

  /// Opens the quiz.
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSizes.space8,
          children: <Widget>[
            Text(
              context.l10n.tabLearningPath,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            Text(
              context.l10n.comingSoonMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            DepthButton(
              label: context.l10n.quizProvisionalStart,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

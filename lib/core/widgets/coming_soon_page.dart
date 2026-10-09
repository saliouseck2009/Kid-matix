import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Temporary content of a tab whose feature is not delivered yet.
///
/// Each feature replaces it with its own page when its lot is built.
class ComingSoonPage extends StatelessWidget {
  /// Creates a placeholder for the tab named [title].
  const ComingSoonPage({required this.title, super.key});

  /// Localized name of the tab.
  final String title;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color mutedColor = context.palette.mutedText;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: AppSizes.space8),
          Text(
            context.l10n.comingSoonMessage,
            style: textTheme.bodyMedium?.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}

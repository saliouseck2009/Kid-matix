import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';

/// Top of a page of the class mode: a back button, the title and an
/// optional action on the right, as on the settings page.
class ClassroomPageHeader extends StatelessWidget {
  /// Creates the header titled [title].
  const ClassroomPageHeader({
    required this.title,
    required this.onBack,
    this.subtitle,
    this.backIcon = Icons.arrow_back_rounded,
    this.backTooltip,
    super.key,
  });

  /// Title of the page.
  final String title;

  /// Line under the title, or `null`.
  final String? subtitle;

  /// Goes back to the parent page.
  final VoidCallback onBack;

  /// Icon of the back button.
  final IconData backIcon;

  /// Tooltip of the back button; « Retour » when `null`.
  final String? backTooltip;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: backIcon,
          tooltip: backTooltip ?? context.l10n.commonBack,
          onPressed: onBack,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(title, style: textTheme.headlineMedium),
              ),
              if (subtitle case final String line)
                Text(
                  line,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

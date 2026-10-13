import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// An action of the settings screen that opens something else, with a
/// chevron at its end, such as "Exporter mon profil".
class SettingsLinkRow extends StatelessWidget {
  /// Creates the row of [label].
  const SettingsLinkRow({required this.label, required this.onTap, super.key});

  static const double _chevronSize = 22;

  /// Name of the action.
  final String label;

  /// Starts the action; `null` while it cannot be started.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget + AppSizes.space8,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: _chevronSize,
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

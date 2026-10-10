import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// A group of the settings screen: its name, then its rows on a white
/// card, separated by thin lines.
class SettingsSection extends StatelessWidget {
  /// Creates the section [title] holding [rows].
  const SettingsSection({required this.title, required this.rows, super.key});

  static const double _radius = 22;
  static const double _dividerThickness = 2;

  /// Name of the section, such as "Sons".
  final String title;

  /// Rows of the section.
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: context.palette.mutedText),
          ),
        ),
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int index = 0; index < rows.length; index++) ...<Widget>[
                  if (index > 0)
                    Divider(
                      height: _dividerThickness,
                      thickness: _dividerThickness,
                      color: context.palette.tint,
                    ),
                  rows[index],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A setting turned on or off with a switch.
class SettingsSwitchRow extends StatelessWidget {
  /// Creates the row of [label].
  const SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Name of the setting.
  final String label;

  /// Whether it is on.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// A setting with its name above its choices.
class SettingsChoiceRow extends StatelessWidget {
  /// Creates the row of [label] with [choices] under it.
  const SettingsChoiceRow({
    required this.label,
    required this.choices,
    super.key,
  });

  /// Name of the setting.
  final String label;

  /// The choices, such as a row of segments.
  final Widget choices;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          choices,
        ],
      ),
    );
  }
}

/// An action of the settings screen that cannot be undone, in red.
class SettingsDangerRow extends StatelessWidget {
  /// Creates the row of [label].
  const SettingsDangerRow({
    required this.label,
    required this.onTap,
    super.key,
  });

  /// Name of the action.
  final String label;

  /// Starts the action, after its confirmation.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget + AppSizes.space8,
          ),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}

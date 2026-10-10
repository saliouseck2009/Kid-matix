import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// A table of the training screen that the child chooses or leaves out:
/// a raised button, filled when chosen.
class TableToggle extends StatelessWidget {
  /// Creates the button of a table marked [mark].
  const TableToggle({
    required this.mark,
    required this.name,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  static const double _height = 64;
  static const double _labelSize = 24;

  /// Mark shown, such as "×5".
  final String mark;

  /// Name read by a screen reader, such as "Table de 5".
  final String name;

  /// Whether the table is chosen.
  final bool isSelected;

  /// Chooses the table or leaves it out.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color edge = isSelected
        ? context.palette.primaryDepth
        : context.palette.border;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusMedium);
    return Semantics(
      button: true,
      selected: isSelected,
      label: name,
      child: Container(
        padding: const EdgeInsets.only(bottom: AppSizes.buttonDepth),
        decoration: BoxDecoration(color: edge, borderRadius: radius),
        child: Material(
          color: isSelected ? scheme.primary : scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: edge, width: AppSizes.borderWidth),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: SizedBox(
              height: _height - AppSizes.buttonDepth,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ExcludeSemantics(
                    child: Text(
                      mark,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: _labelSize,
                        color: isSelected ? scheme.onPrimary : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

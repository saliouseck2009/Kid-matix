import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_mark.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_picker_sheet.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/raised_tile.dart';

/// The domain the player follows, such as « Multiplication », and
/// « Changer », which opens « Mes parcours »; on the map and in the
/// Profile. The domain choice and the progress come from the enclosing
/// `DomainChoiceCubit` and `PathOverviewCubit`.
class DomainButton extends StatelessWidget {
  /// Creates the button of [domainId].
  const DomainButton({required this.domainId, super.key});

  /// Domain followed.
  final String domainId;

  /// Width and height of the domain tile.
  static const double markSize = 40;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color action = context.palette.primaryText;
    return Semantics(
      button: true,
      label: context.l10n.pathDomainButtonSpoken(
        context.l10n.domainSpokenName(domainId),
      ),
      excludeSemantics: true,
      child: RaisedTile(
        onTap: () => showPathPicker(context),
        outline: context.palette.border,
        depth: context.palette.border,
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.space8,
          AppSizes.space8,
          AppSizes.space12,
          AppSizes.space8,
        ),
        child: Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            DomainMark(domainId: domainId, size: markSize),
            Expanded(
              child: Text(
                context.l10n.domainName(domainId),
                style: textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              context.l10n.pathDomainChange,
              style: textTheme.labelLarge?.copyWith(color: action),
            ),
            Icon(Icons.expand_more_rounded, color: action),
          ],
        ),
      ),
    );
  }
}

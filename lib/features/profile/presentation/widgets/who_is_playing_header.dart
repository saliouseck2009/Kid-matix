import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/presentation/widgets/mascot_illustration.dart';

/// Mascot, title and invitation at the top of "Qui joue ?".
class WhoIsPlayingHeader extends StatelessWidget {
  /// Creates the header.
  const WhoIsPlayingHeader({super.key});

  static const double _mascotSize = 104;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        const MascotIllustration(size: _mascotSize),
        const SizedBox(height: AppSizes.space8),
        Semantics(
          header: true,
          child: Text(
            context.l10n.whoIsPlayingTitle,
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        Text(
          context.l10n.whoIsPlayingSubtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
      ],
    );
  }
}

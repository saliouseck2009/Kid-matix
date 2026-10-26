import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// One line that tells an adult the audio pack of the help language is made
/// of machine-made stand-ins, to be replaced by real recordings.
///
/// Shown in the teacher area and under the « Aide audio » setting while the
/// manifest of the pack is flagged `provisional`; never on the child's
/// screens.
class ProvisionalAudioNotice extends StatelessWidget {
  /// Creates the notice.
  const ProvisionalAudioNotice({required this.languageCode, super.key});

  /// Code of the help language whose pack is provisional, such as `wo`.
  final String languageCode;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.space8,
      children: <Widget>[
        ExcludeSemantics(
          child: Icon(
            Icons.info_outline_rounded,
            size: _iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            context.l10n.audioPackProvisionalNotice(
              context.l10n.helpAudioLanguageName(languageCode),
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

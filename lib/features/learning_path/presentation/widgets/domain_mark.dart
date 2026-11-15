import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';

/// The colored tile of a learning domain, with its sign: × for the
/// multiplication, 12 for the numbers, +− for the additions... It tells
/// the domains apart for a child who reads little. Decorative: the name
/// of the domain is always written next to it.
///
/// A new domain adds its color and sign to [_markOf]; until then it shows
/// the first letter of its id on the tint.
class DomainMark extends StatelessWidget {
  /// Creates the tile of [domainId], [size] wide and high.
  const DomainMark({required this.domainId, required this.size, super.key});

  /// Learning domain.
  final String domainId;

  /// Width and height of the tile.
  final double size;

  /// Share of [size] taken by the sign.
  static const double _signRatio = 0.55;

  /// Share of [size] taken by a sign written as text.
  static const double _textRatio = 0.46;

  @override
  Widget build(BuildContext context) {
    final _Mark mark = _markOf(context);
    final Color foreground = mark.isLight
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onPrimary;
    final IconData? icon = mark.icon;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mark.color,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: icon != null
            ? Icon(icon, size: size * _signRatio, color: foreground)
            : Text(
                mark.text,
                textScaler: TextScaler.noScaling,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontSize: size * _textRatio,
                  height: 1,
                ),
              ),
      ),
    );
  }

  _Mark _markOf(BuildContext context) {
    final List<Color> colors = context.palette.avatarBackgrounds;
    return switch (domainId) {
      LearningDomainIds.multiplication => _Mark(
        color: colors[0],
        icon: Icons.close_rounded,
      ),
      LearningDomainIds.numbers => _Mark(color: colors[4], text: '12'),
      LearningDomainIds.addition => _Mark(color: colors[1], text: '+−'),
      LearningDomainIds.division => _Mark(color: colors[5], text: '÷'),
      LearningDomainIds.mathWords => _Mark(
        color: colors[2],
        icon: Icons.chat_rounded,
        isLight: true,
      ),
      LearningDomainIds.problems => _Mark(
        color: colors[3],
        icon: Icons.view_agenda_rounded,
      ),
      _ => _Mark(
        color: context.palette.tint,
        text: domainId.isEmpty ? '' : domainId[0].toUpperCase(),
        isLight: true,
      ),
    };
  }
}

/// Color and sign of a domain tile.
final class _Mark {
  const _Mark({
    required this.color,
    this.icon,
    this.text = '',
    this.isLight = false,
  });

  final Color color;
  final IconData? icon;
  final String text;

  /// Whether [color] is light, so the sign is dark.
  final bool isLight;
}

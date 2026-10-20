import 'package:meta/meta.dart';

/// One skill of the placement test, such as adding: a few units of a
/// learning domain and the typical questions that tell whether the child
/// has the skill.
///
/// The units are named by their key only, so the placement test knows no
/// domain feature; the domain gives the items at run time.
@immutable
final class SkillLevel {
  /// Creates the skill [id] of [domainId].
  ///
  /// [unitKeys] are the units the skill covers, in path order; every one of
  /// [probeUnitKeys] is one of them, from the easiest to the hardest.
  SkillLevel({
    required this.id,
    required this.domainId,
    required List<String> unitKeys,
    required List<String> probeUnitKeys,
  }) : unitKeys = List<String>.unmodifiable(unitKeys),
       probeUnitKeys = List<String>.unmodifiable(probeUnitKeys),
       assert(
         probeUnitKeys.every(unitKeys.contains),
         'every probe is a unit of the skill',
       ),
       assert(probeUnitKeys.length >= passMark, 'the skill can be acquired');

  /// Right answers needed among the typical questions to have the skill:
  /// one slip does not stop the climb.
  static const int passMark = 2;

  /// Stable identifier, such as `addition`.
  final String id;

  /// Learning domain that teaches the skill; the addition and the
  /// subtraction share one.
  final String domainId;

  /// Units of the skill in path order.
  final List<String> unitKeys;

  /// Units the typical questions are drawn from, easiest first.
  final List<String> probeUnitKeys;

  /// Wrong answers that make the skill missed: one more than the typical
  /// questions can spare.
  int get failureMark => probeUnitKeys.length - passMark + 1;

  /// The units of the skill from the first one to [unitKey], both
  /// included: a child who answers a hard unit right knows the easier ones
  /// before it.
  List<String> unitKeysUpTo(String unitKey) {
    final int index = unitKeys.indexOf(unitKey);
    return index < 0 ? const <String>[] : unitKeys.sublist(0, index + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SkillLevel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SkillLevel($id)';
}

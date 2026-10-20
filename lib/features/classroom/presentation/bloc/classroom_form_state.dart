import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:meta/meta.dart';

/// How the teacher gives the pupils of a class.
enum PupilEntryMode {
  /// A list of nicknames, one per line.
  list,

  /// A number of pupils, numbered « 01 », « 02 »...
  numbers,
}

/// Why the form of a class cannot be saved.
enum ClassroomFormProblem {
  /// The name is empty or too long.
  name,

  /// No pupil is given.
  noPupil,

  /// The class would hold more than [ClassroomRules.maxPupils] pupils.
  tooMany,

  /// Some nicknames cannot be used; see [ClassroomFormState.unusable].
  unusable,

  /// A nickname is already in the class.
  taken,

  /// The class could not be saved.
  failure,
}

/// The form that creates a class or adds pupils to one.
@immutable
final class ClassroomFormState {
  /// Creates the state.
  const ClassroomFormState({
    this.isAddition = false,
    this.name = '',
    this.mode = PupilEntryMode.list,
    this.listText = '',
    this.numberCount = 0,
    this.existingCount = 0,
    this.unusable = const <String>[],
    this.problem,
    this.isSaving = false,
    this.savedClassroomId,
  });

  /// Whether the form adds pupils to an existing class rather than
  /// creating one.
  final bool isAddition;

  /// Name typed for a new class.
  final String name;

  /// How the pupils are given.
  final PupilEntryMode mode;

  /// Nicknames typed, one per line.
  final String listText;

  /// How many numbered pupils to create.
  final int numberCount;

  /// Pupils already in the class, so the numbers go on after them.
  final int existingCount;

  /// Nicknames that cannot be used, shown with [problem].
  final List<String> unusable;

  /// Why the last save was refused, or `null`.
  final ClassroomFormProblem? problem;

  /// Whether the class is being saved.
  final bool isSaving;

  /// The class once saved; the page then opens it.
  final String? savedClassroomId;

  /// The nicknames the form would create, in order.
  List<String> get nicknames {
    return switch (mode) {
      PupilEntryMode.list => ClassroomRules.parseNicknames(listText),
      PupilEntryMode.numbers => ClassroomRules.numberNicknames(
        count: numberCount,
        existingCount: existingCount,
      ),
    };
  }

  /// Returns a copy with the given fields replaced, without problem.
  ClassroomFormState copyWith({
    String? name,
    PupilEntryMode? mode,
    String? listText,
    int? numberCount,
    int? existingCount,
    List<String>? unusable,
    ClassroomFormProblem? problem,
    bool? isSaving,
    String? savedClassroomId,
  }) {
    return ClassroomFormState(
      isAddition: isAddition,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      listText: listText ?? this.listText,
      numberCount: numberCount ?? this.numberCount,
      existingCount: existingCount ?? this.existingCount,
      unusable: unusable ?? const <String>[],
      problem: problem,
      isSaving: isSaving ?? false,
      savedClassroomId: savedClassroomId,
    );
  }
}

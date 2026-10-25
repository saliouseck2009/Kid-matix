import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_state.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_use_cases.dart';

/// Drives the creation of a class with its pupils, or the addition of
/// pupils to the class [classroomId].
///
/// The nicknames are checked before anything is written, so the teacher
/// sees which ones to fix.
final class ClassroomFormCubit extends Cubit<ClassroomFormState> {
  /// Creates the Cubit; [classroomId] for an addition of pupils.
  ClassroomFormCubit({required this._useCases, this.classroomId})
    : super(ClassroomFormState(isAddition: classroomId != null));

  final ClassroomFormUseCases _useCases;

  /// Class that receives the pupils, or `null` to create one.
  final String? classroomId;

  /// Reads how many pupils the class already holds, for an addition.
  Future<void> load() async {
    final String? id = classroomId;
    if (id == null) return;
    final DataState<ClassroomRoster> read = await _useCases.getRoster(
      params: id,
    );
    if (isClosed) return;
    if (read case DataSuccess<ClassroomRoster>(:final data)) {
      emit(state.copyWith(existingCount: data.pupils.length));
    }
  }

  /// Keeps the class name typed.
  void changeName(String name) => emit(state.copyWith(name: name));

  /// Switches between a list of nicknames and numbers.
  void changeMode(PupilEntryMode mode) => emit(state.copyWith(mode: mode));

  /// Keeps the nicknames typed.
  void changeList(String text) => emit(state.copyWith(listText: text));

  /// Keeps the number of numbered pupils typed; anything else counts 0.
  void changeNumberCount(String text) {
    emit(state.copyWith(numberCount: int.tryParse(text.trim()) ?? 0));
  }

  /// Checks the form, then saves the class or the new pupils.
  Future<void> submit() async {
    if (state.isSaving) return;
    final List<String> nicknames = state.nicknames;
    final ClassroomFormProblem? problem = _findProblem(nicknames);
    if (problem != null) {
      emit(state.copyWith(problem: problem));
      return;
    }
    final List<String> unusable = await _useCases.findUnusable(
      params: nicknames,
    );
    if (isClosed) return;
    if (unusable.isNotEmpty) {
      emit(
        state.copyWith(
          problem: ClassroomFormProblem.unusable,
          unusable: unusable,
        ),
      );
      return;
    }
    emit(state.copyWith(isSaving: true));
    await _save(nicknames);
  }

  ClassroomFormProblem? _findProblem(List<String> nicknames) {
    if (!state.isAddition && ClassroomRules.cleanName(state.name) == null) {
      return ClassroomFormProblem.name;
    }
    if (nicknames.isEmpty) return ClassroomFormProblem.noPupil;
    if (state.existingCount + nicknames.length > ClassroomRules.maxPupils) {
      return ClassroomFormProblem.tooMany;
    }
    return null;
  }

  Future<void> _save(List<String> nicknames) async {
    final String? id = classroomId;
    final DataState<String> saved = id == null
        ? await _create(nicknames)
        : await _add(id, nicknames);
    if (isClosed) return;
    emit(switch (saved) {
      DataSuccess<String>(:final data) => state.copyWith(
        savedClassroomId: data,
      ),
      DataFailed<String>(:final exception) => state.copyWith(
        problem: _problemOf(exception.code),
      ),
    });
  }

  Future<DataState<String>> _create(List<String> nicknames) async {
    return switch (await _useCases.create(
      params: CreateClassroomParams(name: state.name, nicknames: nicknames),
    )) {
      DataSuccess<ClassroomEntity>(:final data) => DataSuccess<String>(
        data.id,
      ),
      DataFailed<ClassroomEntity>(:final exception) => DataFailed<String>(
        exception,
      ),
    };
  }

  Future<DataState<String>> _add(String id, List<String> nicknames) async {
    return switch (await _useCases.addPupils(
      params: AddPupilsParams(classroomId: id, nicknames: nicknames),
    )) {
      DataSuccess<int>() => DataSuccess<String>(id),
      DataFailed<int>(:final exception) => DataFailed<String>(exception),
    };
  }

  static ClassroomFormProblem _problemOf(AppErrorCode code) {
    return switch (code) {
      AppErrorCode.limitReached => ClassroomFormProblem.tooMany,
      AppErrorCode.conflict => ClassroomFormProblem.taken,
      _ => ClassroomFormProblem.failure,
    };
  }
}

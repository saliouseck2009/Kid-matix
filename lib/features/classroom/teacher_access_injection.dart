import 'package:get_it/get_it.dart';
import 'package:kid_matix/features/classroom/domain/usecases/choose_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/forget_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_access_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_code_change_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_teacher_area_use_case.dart';

/// Registers the door of the teacher area (F29-03) in [sl]: its code,
/// its opening and its closing.
void registerTeacherAccess(GetIt sl) {
  sl.registerLazySingleton<GetTeacherAccessUseCase>(
    () => GetTeacherAccessUseCase(codes: sl(), session: sl()),
  );
  sl.registerLazySingleton<ChooseTeacherCodeUseCase>(
    () => ChooseTeacherCodeUseCase(codes: sl(), session: sl(), clock: sl()),
  );
  sl.registerLazySingleton<OpenTeacherAreaUseCase>(
    () => OpenTeacherAreaUseCase(
      codes: sl(),
      lock: sl(),
      attempts: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<GetTeacherCodeChangeUseCase>(
    () => GetTeacherCodeChangeUseCase(codes: sl()),
  );
  sl.registerLazySingleton<ForgetTeacherCodeUseCase>(
    () => ForgetTeacherCodeUseCase(codes: sl(), attempts: sl()),
  );
  sl.registerLazySingleton<CloseTeacherAreaUseCase>(
    () => CloseTeacherAreaUseCase(session: sl()),
  );
}

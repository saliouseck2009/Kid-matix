import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/classroom/presentation/classroom_pages.dart';

/// The routes of the class mode, outside the tabs: the teacher area
/// (its door, « Mes classes », the creation of a class, the page of a
/// class and « Ajouter des élèves ») and « Qui es-tu ? » of a class.
///
/// The router redirect keeps the area behind its door
/// (`redirectForTeacherArea`).
List<RouteBase> createClassroomRoutes({required ClassroomPages pages}) {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.teacherArea,
      builder: (BuildContext context, GoRouterState state) {
        return pages.buildTeacherAccessPage(
          onBack: () => context.go(AppRoutes.whoIsPlaying),
        );
      },
      routes: <RouteBase>[_classroomsRoute(pages)],
    ),
    GoRoute(
      path: AppRoutes.pupilPicker,
      builder: (BuildContext context, GoRouterState state) {
        return pages.buildPupilPickerPage(
          classroomId: _classroomIdOf(state),
          onBack: () => context.go(AppRoutes.whoIsPlaying),
        );
      },
    ),
  ];
}

GoRoute _classroomsRoute(ClassroomPages pages) {
  return GoRoute(
    path: _lastSegment(AppRoutes.teacherClassrooms),
    builder: (BuildContext context, GoRouterState state) {
      return pages.buildTeacherClassroomsPage(
        onOpenClassroom: (String classroomId) =>
            context.go(AppRoutes.teacherClassroomOf(classroomId)),
        onCreate: () => context.go(AppRoutes.classroomCreation),
        onLeave: () => context.go(AppRoutes.whoIsPlaying),
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: _lastSegment(AppRoutes.classroomCreation),
        builder: (BuildContext context, GoRouterState state) {
          return pages.buildClassroomFormPage(
            onBack: () => context.go(AppRoutes.teacherClassrooms),
            onSaved: (String classroomId) =>
                context.go(AppRoutes.teacherClassroomOf(classroomId)),
          );
        },
      ),
      GoRoute(
        path: ':${AppRoutes.classroomIdParameter}',
        builder: (BuildContext context, GoRouterState state) {
          final String classroomId = _classroomIdOf(state);
          return pages.buildTeacherClassroomPage(
            classroomId: classroomId,
            onBack: () => context.go(AppRoutes.teacherClassrooms),
            onAddPupils: () => context.go(
              AppRoutes.classroomPupilsAdditionOf(classroomId),
            ),
            onGiveAssignment: () =>
                context.go(AppRoutes.classroomAssignmentOf(classroomId)),
          );
        },
        routes: <RouteBase>[
          _pupilsAdditionRoute(pages),
          _assignmentRoute(pages),
        ],
      ),
    ],
  );
}

GoRoute _pupilsAdditionRoute(ClassroomPages pages) {
  return GoRoute(
    path: _lastSegment(AppRoutes.classroomPupilsAddition),
    builder: (BuildContext context, GoRouterState state) {
      final String classroomId = _classroomIdOf(state);
      void openClassroom() {
        context.go(AppRoutes.teacherClassroomOf(classroomId));
      }

      return pages.buildClassroomFormPage(
        classroomId: classroomId,
        onBack: openClassroom,
        onSaved: (String _) => openClassroom(),
      );
    },
  );
}

GoRoute _assignmentRoute(ClassroomPages pages) {
  return GoRoute(
    path: _lastSegment(AppRoutes.classroomAssignment),
    builder: (BuildContext context, GoRouterState state) {
      final String classroomId = _classroomIdOf(state);
      return pages.buildAssignmentPage(
        classroomId: classroomId,
        onBack: () => context.go(AppRoutes.teacherClassroomOf(classroomId)),
      );
    },
  );
}

String _classroomIdOf(GoRouterState state) {
  return state.pathParameters[AppRoutes.classroomIdParameter] ?? '';
}

/// Path of a sub-route, relative to its parent route.
String _lastSegment(String path) => path.split('/').last;

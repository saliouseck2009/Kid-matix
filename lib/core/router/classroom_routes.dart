import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/classroom/presentation/class_assessment_pages.dart';
import 'package:kid_matix/features/classroom/presentation/classroom_pages.dart';
import 'package:kid_matix/features/classroom/presentation/printable_pages.dart';
import 'package:kid_matix/features/classroom/presentation/results_qr_pages.dart';
import 'package:kid_matix/features/classroom/presentation/teacher_audio_pages.dart';

/// The routes of the class mode, outside the tabs: the teacher area
/// (its door, « Mes classes », the creation of a class, the page of a
/// class, « Ajouter des élèves », « Évaluations et rapports ») and « Qui
/// es-tu ? » of a class.
///
/// The router redirect keeps the area behind its door
/// (`redirectForTeacherArea`).
List<RouteBase> createClassroomRoutes({
  required ClassroomPages pages,
  ClassAssessmentPages? assessmentPages,
  ResultsQrPages? qrPages,
  TeacherAudioPages? audioPages,
}) {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.teacherArea,
      builder: (BuildContext context, GoRouterState state) {
        return pages.buildTeacherAccessPage(
          onBack: () => context.go(AppRoutes.whoIsPlaying),
        );
      },
      routes: <RouteBase>[
        _classroomsRoute(
          pages,
          (assessments: assessmentPages, qr: qrPages, audio: audioPages),
        ),
      ],
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

/// The pages of the tools of F31 in the teacher area, each optional.
typedef _ToolPages = ({
  ClassAssessmentPages? assessments,
  ResultsQrPages? qr,
  TeacherAudioPages? audio,
});

GoRoute _classroomsRoute(ClassroomPages pages, _ToolPages tools) {
  final ClassAssessmentPages? assessmentPages = tools.assessments;
  final ResultsQrPages? qrPages = tools.qr;
  final TeacherAudioPages? audioPages = tools.audio;
  return GoRoute(
    path: _lastSegment(AppRoutes.teacherClassrooms),
    builder: (BuildContext context, GoRouterState state) {
      return pages.buildTeacherClassroomsPage(
        onOpenClassroom: (String classroomId) =>
            context.go(AppRoutes.teacherClassroomOf(classroomId)),
        onCreate: () => context.go(AppRoutes.classroomCreation),
        onLeave: () => context.go(AppRoutes.whoIsPlaying),
        actions: <Widget>[
          ?qrPages?.buildReceiveButton(
            onOpen: () => context.go(AppRoutes.resultsQrScan),
          ),
          ?assessmentPages?.reports.buildProgramReportButton(
            onOpen: () => context.go(AppRoutes.programReport),
          ),
          ?audioPages?.buildOpenButton(
            onOpen: () => context.go(AppRoutes.teacherRecordings),
          ),
          ?assessmentPages?.reports.printables?.buildOpenButton(
            onOpen: () => context.go(AppRoutes.printables),
          ),
        ],
      );
    },
    routes: <RouteBase>[
      ?_programReportRoute(assessmentPages),
      ?_qrScanRoute(qrPages),
      ?_recordingsRoute(audioPages),
      ?_printablesRoute(assessmentPages?.reports.printables),
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
            actions: <Widget>[
              ?qrPages?.buildSendButton(
                onOpen: () => context.go(AppRoutes.resultsQrOf(classroomId)),
              ),
              ?assessmentPages?.buildAssessmentsButton(
                onOpen: () =>
                    context.go(AppRoutes.classroomAssessmentsOf(classroomId)),
              ),
            ],
          );
        },
        routes: <RouteBase>[
          _pupilsAdditionRoute(pages),
          _assignmentRoute(pages),
          ?_assessmentsRoute(assessmentPages),
          ?_qrSendRoute(qrPages),
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

GoRoute? _printablesRoute(PrintablePages? pages) {
  if (pages == null) return null;
  return GoRoute(
    path: _lastSegment(AppRoutes.printables),
    builder: (BuildContext context, GoRouterState state) {
      return pages.buildPage(
        onBack: () => context.go(AppRoutes.teacherClassrooms),
      );
    },
  );
}

GoRoute? _recordingsRoute(TeacherAudioPages? pages) {
  if (pages == null) return null;
  return GoRoute(
    path: _lastSegment(AppRoutes.teacherRecordings),
    builder: (BuildContext context, GoRouterState state) {
      return pages.buildPage(
        onBack: () => context.go(AppRoutes.teacherClassrooms),
      );
    },
  );
}

GoRoute? _qrScanRoute(ResultsQrPages? pages) {
  if (pages == null) return null;
  return GoRoute(
    path: _lastSegment(AppRoutes.resultsQrScan),
    builder: (BuildContext context, GoRouterState state) {
      return pages.buildReceivePage(
        onBack: () => context.go(AppRoutes.teacherClassrooms),
      );
    },
  );
}

GoRoute? _qrSendRoute(ResultsQrPages? pages) {
  if (pages == null) return null;
  return GoRoute(
    path: _lastSegment(AppRoutes.resultsQr),
    builder: (BuildContext context, GoRouterState state) {
      final String classroomId = _classroomIdOf(state);
      return pages.buildSendPage(
        classroomId: classroomId,
        onBack: () => context.go(AppRoutes.teacherClassroomOf(classroomId)),
      );
    },
  );
}

GoRoute? _programReportRoute(ClassAssessmentPages? pages) {
  if (pages == null) return null;
  return GoRoute(
    path: _lastSegment(AppRoutes.programReport),
    builder: (BuildContext context, GoRouterState state) {
      return pages.reports.buildProgramReportPage(
        onBack: () => context.go(AppRoutes.teacherClassrooms),
      );
    },
  );
}

GoRoute? _assessmentsRoute(ClassAssessmentPages? pages) {
  if (pages == null) return null;
  return GoRoute(
    path: _lastSegment(AppRoutes.classroomAssessments),
    builder: (BuildContext context, GoRouterState state) {
      final String classroomId = _classroomIdOf(state);
      return pages.buildAssessmentsPage(
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

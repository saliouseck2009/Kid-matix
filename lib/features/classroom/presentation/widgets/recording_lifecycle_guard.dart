import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_recordings_cubit.dart';

/// Throws away a recording in progress as soon as the app is hidden or
/// goes to the background: the microphone is never left on.
class RecordingLifecycleGuard extends StatefulWidget {
  /// Creates the guard around [child]; the Cubit comes from above.
  const RecordingLifecycleGuard({required this.child, super.key});

  /// The page.
  final Widget child;

  @override
  State<RecordingLifecycleGuard> createState() =>
      _RecordingLifecycleGuardState();
}

class _RecordingLifecycleGuardState extends State<RecordingLifecycleGuard> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onHide: _pause, onPause: _pause);
  }

  void _pause() => context.read<TeacherRecordingsCubit>().pause();

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

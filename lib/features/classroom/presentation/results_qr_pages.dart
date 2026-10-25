import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/results_qr_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/results_qr_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/results_qr_scan_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/camera_qr_scanner.dart';

/// Builds the QR codes of results (F31-05): shown by a pupils' tablet,
/// read by the teacher's, both in the teacher area.
final class ResultsQrPages {
  /// Creates the factory; [scanner] draws the camera, the device's by
  /// default.
  ResultsQrPages({required this._useCases, QrScannerBuilder? scanner})
    : _scanner = scanner ?? _cameraOf;

  final ResultsQrUseCases _useCases;
  final QrScannerBuilder _scanner;

  static Widget _cameraOf(BuildContext context, ValueChanged<String> onRead) {
    return CameraQrScanner(onRead: onRead);
  }

  /// « Envoyer par QR code » at the bottom of the page of a class.
  Widget buildSendButton({required VoidCallback onOpen}) {
    return _button(Icons.qr_code_2_rounded, onOpen, isSending: true);
  }

  /// « Recevoir par QR code » under « Mes classes ».
  Widget buildReceiveButton({required VoidCallback onOpen}) {
    return _button(Icons.qr_code_scanner_rounded, onOpen, isSending: false);
  }

  Widget _button(
    IconData icon,
    VoidCallback onOpen, {
    required bool isSending,
  }) {
    return Builder(
      builder: (BuildContext context) => DepthButton(
        label: isSending
            ? context.l10n.classroomQrSend
            : context.l10n.classroomQrReceive,
        icon: icon,
        variant: DepthButtonVariant.secondary,
        onPressed: onOpen,
      ),
    );
  }

  /// The QR code of the new results of [classroomId].
  Widget buildSendPage({
    required String classroomId,
    required VoidCallback onBack,
  }) {
    return BlocProvider<ResultsQrCubit>(
      create: (_) => ResultsQrCubit(useCases: _useCases)..show(classroomId),
      child: ResultsQrPage(classroomId: classroomId, onBack: onBack),
    );
  }

  /// The camera that reads a QR code of results.
  Widget buildReceivePage({required VoidCallback onBack}) {
    return BlocProvider<ResultsQrCubit>(
      create: (_) => ResultsQrCubit(useCases: _useCases),
      child: ResultsQrScanPage(scanner: _scanner, onBack: onBack),
    );
  }
}

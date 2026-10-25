import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/results_qr_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/results_qr_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/results_qr_messages.dart';

/// Builds the camera view that reads QR codes and gives their text.
typedef QrScannerBuilder = Widget Function(
  BuildContext context,
  ValueChanged<String> onRead,
);

/// « Recevoir par QR code »: the camera reads the code another tablet
/// shows, and its results are merged. The camera permission is asked
/// here, in the teacher area only, the first time. No mockup: built with
/// the design system (F31).
class ResultsQrScanPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route, [scanner] draws
  /// the camera.
  const ResultsQrScanPage({
    required this.scanner,
    required this.onBack,
    super.key,
  });

  /// The camera view.
  final QrScannerBuilder scanner;

  /// Goes back to « Mes classes ».
  final VoidCallback onBack;

  static const double _viewSize = 300;

  @override
  Widget build(BuildContext context) {
    final ResultsQrCubit cubit = context.read<ResultsQrCubit>();
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSizes.space16,
              children: <Widget>[
                ClassroomPageHeader(
                  title: context.l10n.classroomQrReceive,
                  onBack: onBack,
                ),
                Text(context.l10n.classroomQrScanHint),
                BlocBuilder<ResultsQrCubit, ResultsQrState>(
                  builder: (BuildContext context, ResultsQrState state) {
                    final String? message = switch (state) {
                      ResultsQrMerged(:final report) => context.qrMergedOf(
                        report,
                      ),
                      ResultsQrFailed(:final errorCode) => context.qrFailureOf(
                        errorCode,
                      ),
                      _ => null,
                    };
                    if (state is ResultsQrScanning) {
                      return SizedBox.square(
                        dimension: _viewSize,
                        child: scanner(context, cubit.receive),
                      );
                    }
                    if (message == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSizes.space16,
                      children: <Widget>[
                        Semantics(liveRegion: true, child: Text(message)),
                        DepthButton(
                          label: context.l10n.classroomQrScanAgain,
                          icon: Icons.qr_code_scanner_rounded,
                          variant: DepthButtonVariant.secondary,
                          onPressed: cubit.scanAgain,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/results_qr_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/results_qr_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/results_qr_messages.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// « Envoyer par QR code »: the new results of a class as a QR code for
/// the teacher's tablet, then « C'est reçu ». No mockup: built with the
/// design system (F31).
class ResultsQrPage extends StatelessWidget {
  /// Creates the page of the class [classroomId]; the Cubit comes from
  /// the route.
  const ResultsQrPage({
    required this.classroomId,
    required this.onBack,
    super.key,
  });

  /// Class sent.
  final String classroomId;

  /// Goes back to the page of the class.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
                  title: context.l10n.classroomQrSend,
                  onBack: onBack,
                ),
                BlocBuilder<ResultsQrCubit, ResultsQrState>(
                  builder: (BuildContext context, ResultsQrState state) {
                    return switch (state) {
                      ResultsQrShown() => _ShownCode(
                        state: state,
                        onDone: () => context.read<ResultsQrCubit>().confirm(
                          classroomId,
                        ),
                      ),
                      ResultsQrSent() => Text(context.l10n.classroomQrSent),
                      ResultsQrFailed(:final errorCode) => Text(
                        context.qrFailureOf(errorCode),
                      ),
                      ResultsQrMerged() ||
                      ResultsQrBusy() ||
                      ResultsQrScanning() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    };
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

class _ShownCode extends StatelessWidget {
  const _ShownCode({required this.state, required this.onDone});

  final ResultsQrShown state;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        Text(
          context.l10n.classroomQrSessions(state.sessionCount),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              QrImageView(
                data: state.text,
                // As wide as the screen: the camera reads it from afar.
                size: constraints.maxWidth,
                // Dark modules on a white ground, whatever the color theme:
                // the cameras read nothing else.
                backgroundColor: Colors.white,
                semanticsLabel: context.l10n.classroomQrImageLabel,
              ),
        ),
        Text(context.l10n.classroomQrSendHint),
        DepthButton(
          label: context.l10n.classroomQrDone,
          icon: Icons.check_rounded,
          onPressed: onDone,
        ),
      ],
    );
  }
}

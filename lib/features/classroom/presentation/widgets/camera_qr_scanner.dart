import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The camera view that reads QR codes, over `mobile_scanner`: the
/// system asks the camera permission when it opens, and nothing leaves
/// the device (ML Kit bundled on Android, Vision on iOS).
class CameraQrScanner extends StatefulWidget {
  /// Creates the view; [onRead] gets the text of each code read.
  const CameraQrScanner({required this.onRead, super.key});

  /// Gets the text of a code read.
  final ValueChanged<String> onRead;

  @override
  State<CameraQrScanner> createState() => _CameraQrScannerState();
}

class _CameraQrScannerState extends State<CameraQrScanner> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final Barcode barcode in capture.barcodes) {
      final String? text = barcode.rawValue;
      if (text != null && text.isNotEmpty) {
        widget.onRead(text);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: (BuildContext context, MobileScannerException error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Text(
                context.l10n.classroomQrCameraError,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

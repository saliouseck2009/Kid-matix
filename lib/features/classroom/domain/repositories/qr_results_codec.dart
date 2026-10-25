import 'package:kid_matix/features/classroom/domain/entities/qr_results.dart';

/// Writes small results as the text of a QR code and reads it back.
abstract interface class QrResultsCodec {
  /// The text of the QR code of [results].
  String encode(QrResults results);

  /// The results of [text], read by the camera.
  ///
  /// Throws an `InvalidFileException` when it is no Kid Matix results
  /// code or is damaged, and an `UnsupportedVersionException` when a
  /// newer app wrote it.
  QrResults decode(String text);
}

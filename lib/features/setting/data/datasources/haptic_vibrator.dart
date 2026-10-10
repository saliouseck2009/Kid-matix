import 'package:flutter/services.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';

/// [Vibrator] over the haptic feedback of the phone.
final class HapticVibrator implements Vibrator {
  /// Creates the vibrator.
  const HapticVibrator();

  @override
  Future<void> vibrate(VibrationStrength strength) {
    return switch (strength) {
      VibrationStrength.light => HapticFeedback.lightImpact(),
      VibrationStrength.medium => HapticFeedback.mediumImpact(),
    };
  }
}

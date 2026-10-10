import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/setting/data/datasources/haptic_vibrator.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Object?> vibrations;

  setUp(() {
    vibrations = <Object?>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) {
          if (call.method == 'HapticFeedback.vibrate') {
            vibrations.add(call.arguments);
          }
          return Future<Object?>.value();
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('turns each strength into its haptic impact', () async {
    // Arrange
    const HapticVibrator vibrator = HapticVibrator();
    const List<String> expectedVibrations = <String>[
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
    ];
    // Act
    await vibrator.vibrate(VibrationStrength.light);
    await vibrator.vibrate(VibrationStrength.medium);
    // Assert
    expect(vibrations, expectedVibrations);
  });
}

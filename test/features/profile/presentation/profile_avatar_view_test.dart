import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/widgets/premium_avatar_painter.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_painter.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';

Future<ProfileAvatarPainter> _pumpAvatar(
  WidgetTester tester, {
  required ProfileAvatar avatar,
  required ProfileColor color,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Center(
        child: ProfileAvatarView(avatar: avatar, color: color, size: 64),
      ),
    ),
  );
  final CustomPaint paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(ProfileAvatarView),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as ProfileAvatarPainter;
}

void main() {
  group('avatar colors', () {
    test('the palette has one color per profile color', () {
      // Act
      final int actualCount = AppPalette.light.avatarBackgrounds.length;
      // Assert
      expect(actualCount, ProfileColor.values.length);
    });
  });

  group('ProfileAvatarView', () {
    testWidgets('draws every avatar in every color', (
      WidgetTester tester,
    ) async {
      for (final ProfileColor inputColor in ProfileColor.values) {
        for (final ProfileAvatar inputAvatar in ProfileAvatar.free) {
          // Act
          final ProfileAvatarPainter actualPainter = await _pumpAvatar(
            tester,
            avatar: inputAvatar,
            color: inputColor,
          );
          // Assert
          expect(actualPainter.avatar, inputAvatar);
          expect(
            actualPainter.background,
            AppPalette.light.avatarBackgrounds[inputColor.index],
          );
          expect(tester.takeException(), isNull);
        }
      }
    });
    testWidgets('draws the avatars of the shop in their own colors', (
      WidgetTester tester,
    ) async {
      for (final ProfileAvatar inputAvatar in ProfileAvatar.values.where(
        (ProfileAvatar avatar) => !avatar.isFree,
      )) {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.night,
            home: Center(
              child: ProfileAvatarView(
                avatar: inputAvatar,
                color: ProfileColor.blue,
                size: 64,
              ),
            ),
          ),
        );
        final CustomPaint actualPaint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(ProfileAvatarView),
            matching: find.byType(CustomPaint),
          ),
        );
        // Assert
        expect(
          (actualPaint.painter! as PremiumAvatarPainter).avatar,
          inputAvatar,
        );
        expect(tester.takeException(), isNull);
      }
    });
    testWidgets('draws a dark face on the yellow background', (
      WidgetTester tester,
    ) async {
      // Act
      final ProfileAvatarPainter actualPainter = await _pumpAvatar(
        tester,
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.yellow,
      );
      // Assert
      expect(actualPainter.faceColor, AppColors.ink);
    });
    testWidgets('draws a white face on the violet background', (
      WidgetTester tester,
    ) async {
      // Act
      final ProfileAvatarPainter actualPainter = await _pumpAvatar(
        tester,
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.violet,
      );
      // Assert
      expect(actualPainter.faceColor, AppColors.white);
    });
    testWidgets('is hidden from screen readers', (WidgetTester tester) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      // Act
      await _pumpAvatar(
        tester,
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.violet,
      );
      // Assert
      expect(
        find.descendant(
          of: find.byType(ProfileAvatarView),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('ProfileAvatar', () {
    test('keeps 12 free avatars and 8 from the shop', () {
      // Act and assert
      expect(ProfileAvatar.free, hasLength(12));
      expect(ProfileAvatar.free.every((ProfileAvatar a) => a.isFree), isTrue);
      expect(
        ProfileAvatar.values.where((ProfileAvatar a) => !a.isFree),
        hasLength(8),
      );
    });
  });

  group('PremiumAvatarPainter', () {
    test('repaints only for another avatar', () {
      // Arrange
      const PremiumAvatarPainter inputPainter = PremiumAvatarPainter(
        avatar: ProfileAvatar.fox,
      );
      // Act and assert
      expect(
        inputPainter.shouldRepaint(
          const PremiumAvatarPainter(avatar: ProfileAvatar.fox),
        ),
        isFalse,
      );
      expect(
        inputPainter.shouldRepaint(
          const PremiumAvatarPainter(avatar: ProfileAvatar.king),
        ),
        isTrue,
      );
    });
  });

  group('ProfileAvatarPainter', () {
    test('repaints only when what it draws changes', () {
      // Arrange
      const ProfileAvatarPainter inputPainter = ProfileAvatarPainter(
        avatar: ProfileAvatar.avatar1,
        background: AppColors.violet,
        faceColor: AppColors.white,
      );
      const ProfileAvatarPainter inputSamePainter = ProfileAvatarPainter(
        avatar: ProfileAvatar.avatar1,
        background: AppColors.violet,
        faceColor: AppColors.white,
      );
      const ProfileAvatarPainter inputOtherPainter = ProfileAvatarPainter(
        avatar: ProfileAvatar.avatar7,
        background: AppColors.violet,
        faceColor: AppColors.white,
      );
      // Act
      final bool actualSameRepaint = inputSamePainter.shouldRepaint(
        inputPainter,
      );
      final bool actualOtherRepaint = inputOtherPainter.shouldRepaint(
        inputPainter,
      );
      // Assert
      expect(actualSameRepaint, isFalse);
      expect(actualOtherRepaint, isTrue);
    });
  });
}

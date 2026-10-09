import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_status.dart';
import 'package:meta/meta.dart';

/// Content of the profile creation form.
@immutable
final class ProfileCreationState {
  /// Creates a state with every field given.
  const ProfileCreationState({
    required this.nickname,
    required this.avatar,
    required this.color,
    required this.status,
    required this.showsNicknameError,
    this.failureCode,
  });

  /// Empty form with the first avatar and the violet color.
  const ProfileCreationState.initial()
    : nickname = '',
      avatar = ProfileAvatar.avatar1,
      color = ProfileColor.violet,
      status = ProfileCreationStatus.editing,
      showsNicknameError = false,
      failureCode = null;

  /// Nickname as typed.
  final String nickname;

  /// Chosen character.
  final ProfileAvatar avatar;

  /// Chosen color.
  final ProfileColor color;

  /// Progress of the form.
  final ProfileCreationStatus status;

  /// Whether nickname errors are shown; true after the first submission.
  final bool showsNicknameError;

  /// Why saving failed, when [status] is [ProfileCreationStatus.failed].
  final AppErrorCode? failureCode;

  /// Why the typed nickname breaks the rules, or `null`.
  NicknameError? get nicknameError => NicknameRules.validate(nickname);

  /// Whether the form can be submitted.
  bool get canSubmit =>
      nickname.trim().isNotEmpty && status != ProfileCreationStatus.submitting;

  /// Returns a copy with the given fields replaced; [failureCode] is
  /// cleared unless given.
  ProfileCreationState copyWith({
    String? nickname,
    ProfileAvatar? avatar,
    ProfileColor? color,
    ProfileCreationStatus? status,
    bool? showsNicknameError,
    AppErrorCode? failureCode,
  }) {
    return ProfileCreationState(
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
      status: status ?? this.status,
      showsNicknameError: showsNicknameError ?? this.showsNicknameError,
      failureCode: failureCode,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileCreationState &&
            other.nickname == nickname &&
            other.avatar == avatar &&
            other.color == color &&
            other.status == status &&
            other.showsNicknameError == showsNicknameError &&
            other.failureCode == failureCode;
  }

  @override
  int get hashCode => Object.hash(
    nickname,
    avatar,
    color,
    status,
    showsNicknameError,
    failureCode,
  );
}

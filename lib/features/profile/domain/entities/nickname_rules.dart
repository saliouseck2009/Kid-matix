import 'package:kid_matix/core/utils/text_folding.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';

/// Rules of a player's nickname.
///
/// A nickname has 2 to 12 characters: letters (accented ones included),
/// digits and spaces. Two nicknames are the same when their [normalize]d
/// forms are equal, so "Awa", "awa" and "ÀWA" clash.
abstract final class NicknameRules {
  /// Fewest characters a nickname may have.
  static const int minLength = 2;

  /// Most characters a nickname may have.
  static const int maxLength = 12;

  static final RegExp _allowedCharacters = RegExp(
    r'^[\p{L}\p{N} ]+$',
    unicode: true,
  );
  static final RegExp _spaces = RegExp(r'\s+');

  /// Returns [input] without leading or trailing spaces, with every run of
  /// spaces inside reduced to one: the form that is stored and displayed.
  static String clean(String input) {
    return input.trim().replaceAll(_spaces, ' ');
  }

  /// Returns why [input] cannot be a nickname, or `null` when it can.
  ///
  /// [input] is [clean]ed first, so stray spaces never count.
  static NicknameError? validate(String input) {
    final String nickname = clean(input);
    final int length = nickname.runes.length;
    if (length < minLength) return NicknameError.tooShort;
    if (length > maxLength) return NicknameError.tooLong;
    if (!_allowedCharacters.hasMatch(nickname)) {
      return NicknameError.invalidCharacters;
    }
    return null;
  }

  /// Returns the form of [input] used to check uniqueness: [clean]ed,
  /// lower case, and without accents.
  static String normalize(String input) {
    return TextFolding.fold(clean(input));
  }
}

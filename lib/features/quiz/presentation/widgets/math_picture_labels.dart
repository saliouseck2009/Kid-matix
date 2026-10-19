import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// What a screen reader says for a drawing of a question or a help card.
final class MathPictureLabels {
  /// Creates the labels.
  const MathPictureLabels(this._l10n);

  final AppLocalizations _l10n;

  /// Label of [picture]; [isSolved] tells the count of objects, which a
  /// question keeps hidden since it is the answer. [blankText] is what
  /// the player typed for the hidden number of a line.
  String describe(
    MathPicture picture, {
    bool isSolved = false,
    String? blankText,
  }) {
    return switch (picture) {
      ObjectsPicture(:final int count) =>
        isSolved
            ? _l10n.quizObjectsPictureCounted(count)
            : _l10n.quizObjectsPictureLabel,
      TenBundlesPicture(:final int tens, :final int ones) =>
        _l10n.quizBundlesPictureLabel(tens, ones),
      NumberLinePicture() => _l10n.quizNumberLinePictureLabel(
        listNumbers(picture, blankText: blankText),
      ),
      WordPicture(:final String label) => label,
    };
  }

  /// The numbers of [line] from left to right, separated by commas, the
  /// hidden one said as such unless [blankText] fills it.
  String listNumbers(NumberLinePicture line, {String? blankText}) {
    return <String>[
      for (int index = 0; index < line.values.length; index++)
        index == line.blankIndex
            ? blankText ?? _l10n.quizSpokenHiddenNumber
            : '${line.values[index]}',
    ].join(', ');
  }
}

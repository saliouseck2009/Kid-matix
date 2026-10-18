/// The highest box an answer picked among choices can take an item to,
/// unless its domain says otherwise.
const int defaultRecognizedBoxCap = 3;

/// Implemented by a learning domain that decides how far an answer picked
/// among choices can take an item (a domain that does not implement it
/// keeps [defaultRecognizedBoxCap]).
///
/// The math words are learned by recognizing a drawing or an operation, so
/// recognition has no cap there: the item still needs right answers on
/// spaced days to climb.
abstract interface class RecognitionCap {
  /// The highest box a recognized answer reaches; `null` for no cap.
  int? get recognizedBoxCap;
}

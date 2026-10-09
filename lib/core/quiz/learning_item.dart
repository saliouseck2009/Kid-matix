/// The smallest thing to master, followed by the mastery engine.
///
/// For the multiplication domain, one fact such as 7 x 8.
abstract interface class LearningItem {
  /// Stable key, such as `mul:7x8`; it never changes once released, since
  /// the stored progress refers to it.
  String get key;
}

/// Generates unique identifiers for locally created records.
///
/// Identifiers are created on the device and must stay unique once several
/// devices send their data to a server.
abstract interface class IdGenerator {
  /// Returns a new unique identifier.
  String generateId();
}

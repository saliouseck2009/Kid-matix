import 'dart:async';

/// Tells listeners that the content of a database table changed.
///
/// `sqflite` has no reactive queries: repositories call [notifyChanged] after
/// each write, and the watching use cases reload their data.
final class TableChangeBus {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Emits an event every time [table] changes.
  Stream<String> watchTable({required String table}) {
    return _controller.stream.where((String changed) => changed == table);
  }

  /// Signals that the content of [table] changed.
  void notifyChanged({required String table}) => _controller.add(table);

  /// Releases the underlying stream.
  Future<void> dispose() => _controller.close();
}

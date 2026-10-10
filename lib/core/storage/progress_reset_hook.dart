import 'package:sqflite/sqflite.dart';

/// Erases what a feature keeps of a player's progress, inside the
/// transaction that resets it: all or nothing.
///
/// Implemented in the data layer of each feature that stores progress;
/// the player's identity and settings are never touched.
abstract interface class ProgressResetHook {
  /// Erases the progress of [profileId] in [transaction] and returns the
  /// tables written, to notify once the transaction is committed.
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  });
}

/// The [ProgressResetHook]s of the app, added by each feature at startup.
final class ProgressResetHooks {
  final List<ProgressResetHook> _hooks = <ProgressResetHook>[];

  /// Every hook, in the order they were added.
  List<ProgressResetHook> get hooks =>
      List<ProgressResetHook>.unmodifiable(_hooks);

  /// Adds [hook].
  void add(ProgressResetHook hook) => _hooks.add(hook);
}

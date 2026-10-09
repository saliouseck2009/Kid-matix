import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [LocalStorage] backed by `shared_preferences`.
final class SharedPreferencesLocalStorage implements LocalStorage {
  /// Creates a storage that reads and writes through [preferences].
  const SharedPreferencesLocalStorage({required this._preferences});

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readString({required String key}) {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeString({required String key, required String value}) {
    return _preferences.setString(key, value);
  }

  @override
  Future<void> remove({required String key}) => _preferences.remove(key);
}

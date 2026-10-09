import 'package:kid_matix/core/storage/local_storage.dart';

/// [LocalStorage] kept in memory, for tests.
final class InMemoryLocalStorage implements LocalStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> readString({required String key}) async => _values[key];

  @override
  Future<void> writeString({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> remove({required String key}) async => _values.remove(key);
}

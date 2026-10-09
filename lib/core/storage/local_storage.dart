/// Light key-value storage for non-sensitive preferences.
///
/// Never store secrets here: sensitive data belongs in secure storage.
abstract interface class LocalStorage {
  /// Returns the text stored under [key], or `null` when there is none.
  Future<String?> readString({required String key});

  /// Stores [value] under [key], replacing any previous value.
  Future<void> writeString({required String key, required String value});

  /// Removes whatever is stored under [key].
  Future<void> remove({required String key});
}

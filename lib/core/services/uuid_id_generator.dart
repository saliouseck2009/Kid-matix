import 'package:kid_matix/core/services/id_generator.dart';
import 'package:uuid/uuid.dart';

/// [IdGenerator] that produces random version 4 UUIDs.
final class UuidIdGenerator implements IdGenerator {
  /// Creates a UUID generator.
  const UuidIdGenerator();

  static const Uuid _uuid = Uuid();

  @override
  String generateId() => _uuid.v4();
}

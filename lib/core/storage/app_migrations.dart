import 'package:kid_matix/core/storage/database_migration.dart';

/// Every schema migration of the app database, in version order.
///
/// The list is empty until the first table is created with the profile
/// feature (lot F1); the database is not opened before then.
const List<DatabaseMigration> appMigrations = <DatabaseMigration>[];

import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migrations/migration_001_create_profile_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_002_create_quiz_session_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_003_create_item_progress_table.dart';
import 'package:kid_matix/core/storage/migrations/migration_004_add_quiz_session_source.dart';

/// Every schema migration of the app database, in version order.
///
/// Add a migration at the end for each schema change; never edit or remove
/// one that has been released.
const List<DatabaseMigration> appMigrations = <DatabaseMigration>[
  Migration001CreateProfileTables(),
  Migration002CreateQuizSessionTables(),
  Migration003CreateItemProgressTable(),
  Migration004AddQuizSessionSource(),
];

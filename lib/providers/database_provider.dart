import 'package:drift_app/database/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@riverpod
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();

  ref.onDispose(database.close);

  return database;
}

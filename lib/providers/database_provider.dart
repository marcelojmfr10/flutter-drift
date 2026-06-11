import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';

part 'database_provider.g.dart';

/// Provider que expone la instancia ÚNICA de la base de datos.
///
/// keepAlive: true → los providers anotados son autoDispose por defecto,
/// pero la BD debe vivir durante toda la app (abrir/cerrar SQLite
/// constantemente sería costoso y rompería los streams).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();

  // Buena práctica: cerrar la BD si el provider llegara a destruirse.
  ref.onDispose(database.close);

  return database;
}

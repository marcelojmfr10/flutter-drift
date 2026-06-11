import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'daos/notes_dao.dart';

// Drift genera código en este archivo (data classes, companions...)
// Se crea al correr: dart run build_runner build
part 'database.g.dart';

/// Cada tabla es una clase que extiende [Table].
/// El nombre en SQL se deriva de la clase: Notes -> "notes",
/// y la data class generada será "Note" (Drift quita la "s" final).
class Notes extends Table {
  // Ojo a la sintaxis: cada columna termina con un PAR EXTRA de paréntesis ()
  // porque el builder (integer(), text()...) se "ejecuta" para crear la columna.

  /// PRIMARY KEY autoincremental.
  IntColumn get id => integer().autoIncrement()();

  /// TEXT NOT NULL — en Drift las columnas son NO nulas por defecto.
  /// withLength valida la longitud al insertar/actualizar (lanza excepción).
  TextColumn get title => text().withLength(min: 1, max: 50)();

  /// El nombre del getter en Dart no tiene que coincidir con el de SQL:
  /// .named('content') hace que en la tabla la columna se llame "content".
  TextColumn get body => text().named('content')();

  /// bool se guarda como INTEGER 0/1 en SQLite.
  /// withDefault define el DEFAULT a nivel de SQL.
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();

  /// DateTime se guarda como timestamp Unix (INTEGER) por defecto.
  /// currentDateAndTime = la BD pone la fecha automáticamente al insertar.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Punto de entrada central de la base de datos.
/// Registra todas las tablas y DAOs; Drift genera _$AppDatabase.
@DriftDatabase(tables: [Notes], daos: [NotesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Sube este número con CADA cambio de esquema (nueva tabla/columna)
  /// y escribe la migración correspondiente en MigrationStrategy.

  /// El incremento de [schemaVersion] debe hacerse manualmente cada vez que
  /// cambias el esquema de la base de datos (nuevas tablas, nuevas columnas, cambios significativos).
  /// Si olvidas subirlo, las migraciones NO se ejecutarán.
  @override
  int get schemaVersion => 1;

  /// driftDatabase() abre la BD según la plataforma (iOS, Android, web...).
  /// Crea el archivo "notes_db.sqlite" en el directorio de soporte de la app.
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'notes_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

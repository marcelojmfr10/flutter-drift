import 'package:drift/drift.dart';

import '../database.dart';

part 'notes_dao.g.dart';

/// DAO (Data Access Object): agrupa las consultas de una tabla
/// para no inflar la clase AppDatabase.
/// El mixin generado (_$NotesDaoMixin) nos da acceso directo a `notes`.
@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  /// SELECT reactivo: .watch() devuelve un Stream que RE-EMITE
  /// automáticamente cada vez que la tabla cambia (insert/update/delete).
  /// Esta es la gran ventaja de Drift: la UI se actualiza sola.
  Stream<List<Note>> watchAllNotes() {
    final query = select(notes)
      ..orderBy([
        // Importantes primero, luego las más recientes.
        (n) => OrderingTerm(expression: n.isImportant, mode: OrderingMode.desc),
        (n) => OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc),
      ]);

    return query.watch();
  }

  /// SELECT de un solo registro.
  /// getSingle() lanza excepción si no existe; getSingleOrNull() devuelve null.
  Future<Note> getNoteById(int id) {
    return (select(notes)..where((n) => n.id.equals(id))).getSingle();
  }

  /// INSERT: recibe un Companion (datos parciales) y devuelve el id generado.
  /// NotesCompanion.insert() marca como required las columnas obligatorias
  /// (title y body); id, isImportant y createdAt los resuelve la BD.
  Future<int> insertNote(NotesCompanion note) {
    return into(notes).insert(note);
  }

  /// UPDATE por primary key: replace() busca la fila por su PK
  /// y reemplaza el resto de columnas con los valores de [note].
  /// Devuelve true si encontró (y actualizó) la fila.
  Future<bool> updateNote(Note note) {
    return update(notes).replace(note);
  }

  /// DELETE con where. ¡Sin el where borraría TODA la tabla!
  /// .go() ejecuta y devuelve cuántas filas se eliminaron.
  Future<int> deleteNote(int id) {
    final query = delete(notes)..where((n) => n.id.equals(id));
    return query.go();
  }
}

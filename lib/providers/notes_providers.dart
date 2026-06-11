import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import 'database_provider.dart';

part 'notes_providers.g.dart';

/// Provider del listado, conectado al stream reactivo de Drift.
///
/// Como la función devuelve un Stream, el generador crea un StreamProvider:
/// la UI lo consume como `AsyncValue<List<Note>>` (loading / data / error)
/// y se reconstruye sola con cada cambio en la tabla. Cero código extra.
@riverpod
Stream<List<Note>> allNotes(Ref ref) {
  return ref.watch(appDatabaseProvider).notesDao.watchAllNotes();
}

/// Provider con parámetros (lo que antes era un .family):
/// cada id distinto crea un estado independiente y cacheado.
@riverpod
Future<Note> noteById(Ref ref, {required int id}) {
  return ref.watch(appDatabaseProvider).notesDao.getNoteById(id);
}

import 'package:drift_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/database_provider.dart';
import '../providers/notes_providers.dart';

/// Pantalla de listado. ConsumerWidget = StatelessWidget + WidgetRef.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch en build: la pantalla se reconstruye con cada emisión
    // del stream de Drift. AsyncValue maneja carga, error y datos.
    final notesAsync = ref.watch(allNotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis notas')),

      body: notesAsync.when(
        data: (notes) => _ListItems(notes: notes),
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ListItems extends ConsumerWidget {
  const _ListItems({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) {
      return const Center(child: Text('No hay notas. ¡Crea la primera!'));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: ValueKey(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(appDatabaseProvider).notesDao.deleteNote(note.id);
          },
          child: ListTile(
            title: Text(note.title),
            subtitle: Text(
              note.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: Icon(
                note.isImportant ? Icons.star : Icons.star_border,
                color: note.isImportant ? Colors.amber : null,
              ),
              onPressed: () {
                ref
                    .read(appDatabaseProvider)
                    .notesDao
                    .updateNote(note.copyWith(isImportant: !note.isImportant));
              },
            ),
            onTap: () => context.push('/note/${note.id}'),
          ),
        );
      },
    );
  }
}

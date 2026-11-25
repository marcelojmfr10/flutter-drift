import 'package:drift_app/database/database.dart';
import 'package:drift_app/providers/notes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final notesAsync = ref.watch(allNotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis notas')),

      body: notesAsync.when(
        data: (notes) => _ListItems(notes: notes),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/note/new');
          // final notesDao = ref.read(appDatabaseProvider).notesDao;

          // notesDao.insertNote(
          //   NotesCompanion.insert(title: 'Hola', body: 'Mensaje de prueba'),
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ListItems extends StatelessWidget {
  final List<Note> notes;
  const _ListItems({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(child: Text('No hay notas. ¡Crea la primera!'));
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
          // TODO: borrar en la base de datos cuando exista.
          onDismissed: (_) {
            // setState(() => notes.removeAt(index))
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
              // TODO: actualizar en la base de datos cuando exista.
              onPressed: () {
                //   setState(() {
                //   notes[index] = note.copyWith(
                //     isImportant: !note.isImportant,
                //   );
                // });
              },
            ),
            onTap: () => context.push('/note/${note.id}'),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_notes.dart';
import '../models/note.dart';

/// Pantalla de listado.
/// Stateful solo para reflejar cambios visuales (dismiss, estrella)
/// mientras no haya base de datos.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> notes = MockNotes.notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis notas')),

      body: notes.isEmpty
          ? const Center(child: Text('No hay notas. ¡Crea la primera!'))
          : ListView.builder(
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
                  onDismissed: (_) => setState(() => notes.removeAt(index)),
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
                      onPressed: () => setState(() {
                        notes[index] = note.copyWith(
                          isImportant: !note.isImportant,
                        );
                      }),
                    ),
                    onTap: () => context.push('/note/${note.id}'),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:drift/drift.dart' show Value;
import 'package:drift_app/database/database.dart';
import 'package:drift_app/providers/database_provider.dart';
import 'package:drift_app/providers/notes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de crear / editar.
/// noteId == null -> crear nota nueva.
/// noteId != null -> editar la nota con ese id.
class NoteScreen extends ConsumerWidget {
  const NoteScreen({super.key, this.noteId});

  final int? noteId;

  @override
  Widget build(BuildContext context, ref) {
    // Modo crear: formulario vacío.
    if (noteId == null) {
      return const _NoteForm(note: null);
    }

    final noteAsync = ref.watch(noteByIdProvider(id: noteId!));

    return noteAsync.when(
      data: (note) => _NoteForm(note: note),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}

/// Formulario. Stateful porque los TextEditingController son estado local
/// de la UI.
class _NoteForm extends ConsumerStatefulWidget {
  const _NoteForm({required this.note});

  /// null = crear, con valor = editar.
  final Note? note;

  @override
  ConsumerState<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<_NoteForm> {
  late final titleController = TextEditingController(text: widget.note?.title);
  late final bodyController = TextEditingController(text: widget.note?.body);
  late bool isImportant = widget.note?.isImportant ?? false;

  bool get isEditing => widget.note != null;

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void _save() async {
    final dao = ref.read(appDatabaseProvider).notesDao;
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty) return;
    if (body.isEmpty) return;

    if (isEditing) {
      await dao.updateNote(
        widget.note!.copyWith(
          title: title,
          body: body,
          isImportant: isImportant,
        ),
      );
    } else {
      await dao.insertNote(
        NotesCompanion.insert(
          title: title,
          body: body,
          isImportant: Value(isImportant),
        ),
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar nota' : 'Nueva nota')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: const Text('Importante'),
              value: isImportant,
              onChanged: (value) => setState(() => isImportant = value),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEditing ? 'Guardar cambios' : 'Crear nota'),
            ),
          ],
        ),
      ),
    );
  }
}

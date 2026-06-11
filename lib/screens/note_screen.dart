import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/database.dart';
import '../providers/database_provider.dart';
import '../providers/notes_providers.dart';

/// Pantalla de crear / editar.
/// noteId == null -> crear nota nueva.
/// noteId != null -> cargar la nota de la BD y editarla.
class NoteScreen extends ConsumerWidget {
  const NoteScreen({super.key, this.noteId});

  final int? noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Modo crear: formulario vacío, sin tocar la BD.
    if (noteId == null) {
      return const _NoteForm(note: null);
    }

    // Modo editar: el FutureProvider con parámetro carga la nota.
    final noteAsync = ref.watch(noteByIdProvider(id: noteId!));

    return noteAsync.when(
      data: (note) => _NoteForm(note: note),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Formulario. Stateful porque los TextEditingController son estado local
/// de la UI: no necesitan (ni deben) vivir en un provider.
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

  Future<void> _save() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty) return;

    final dao = ref.read(appDatabaseProvider).notesDao;

    if (isEditing) {
      // UPDATE: la data class + copyWith generan la fila completa
      // y replace() la guarda buscando por primary key.
      await dao.updateNote(
        widget.note!.copyWith(
          title: title,
          body: body,
          isImportant: isImportant,
        ),
      );
    } else {
      // INSERT: el Companion lleva solo los datos que aportamos.
      // - title y body son required (columnas NOT NULL sin default)
      // - isImportant es Value<bool>: si no lo mandáramos
      //   (Value.absent()), la BD usaría su DEFAULT (false).
      // - id y createdAt no se mandan: los resuelve la BD.
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
              maxLength: 50, // coincide con withLength(max: 50) de la tabla
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

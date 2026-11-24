import 'package:material_ui/material_ui.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final database = AppDatabase();
  // await database
  //     .into(database.notes)
  //     .insert(
  //       NotesCompanion.insert(
  //         title: 'todo: finish drift setup',
  //         body: 'We can now write queries and define our own tables.',
  //       ),
  //     );

  // await (database.delete(database.notes)
  // ..where((note) => note.id.equals(1))
  // )
  // .go();

  // List<Note> allNotes = await database.select(database.notes).get();

  // print('items in database: $allNotes');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Notas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      routerConfig: appRouter,
    );
  }
}

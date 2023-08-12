import 'package:flutter/material.dart';
import 'package:project0/services/auth/auth_service.dart';
import 'package:project0/services/cloud/cloud_note.dart';
import 'package:project0/services/cloud/firebase_cloud_storage.dart';
import 'package:project0/views/notes/notes_list.dart';
import '../../constants/routes.dart';
import '../../enums/menu_actions.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  // getter
  String get userId => AuthService.firebase().currentUser!.id; // unwrapping

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    // After creating the SINGLETON (notes_service),
    // the _notesService instance is created from private contructor (see _shared in notes_service)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                createOrUpdateNoteRoute,
              );
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: MenuActions.logout,
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(userId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesList(
                  notes: allNotes,
                  onDeleteNote: (note) async => await _notesService.deleteNotes(
                    documentId: note.documentId,
                  ),
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

// Logout dialog function



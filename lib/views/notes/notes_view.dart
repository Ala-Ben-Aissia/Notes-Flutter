import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project0/services/auth/auth_service.dart';
import 'package:project0/services/bloc/auth_bloc.dart';
import 'package:project0/services/bloc/auth_event.dart';
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
                    if (!mounted) return;
                    context.read<AuthBloc>().add(
                          const AuthEventLogout(),
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

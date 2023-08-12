import 'package:flutter/material.dart';
import 'package:project0/services/auth/auth_service.dart';
import 'package:project0/utilities/generics/get_arguments.dart';
import '../../services/crud/notes_service.dart';

class CreateUpdateNote extends StatefulWidget {
  const CreateUpdateNote({super.key});

  @override
  State<CreateUpdateNote> createState() => _CreateUpdateNoteState();
}

class _CreateUpdateNoteState extends State<CreateUpdateNote> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote
          .text; // previous note text in textController when updating note
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) return existingNote;
    final currentUser = AuthService.firebase().currentUser;
    final email = currentUser!.email;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  // keep updating note while typing
  void _textControllerListener() async {
    final note = _note;
    final text = _textController.text;
    if (note == null) return;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setUptextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _saveNoteIfNotEmpty() {
    final note = _note;
    final text = _textController.text;
    if (_textController.text.isNotEmpty && note != null) {
      _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  @override
  void dispose() {
    _saveNoteIfNotEmpty();
    _deleteNoteIfEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setUptextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your notes',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

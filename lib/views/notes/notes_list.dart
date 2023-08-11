import 'package:flutter/material.dart';
import 'package:project0/utilities/dialogs/delete_note_dialog.dart';

import '../../services/crud/notes_service.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesList extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  const NotesList({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            onTap(note);
          },
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) onDeleteNote(note);
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}

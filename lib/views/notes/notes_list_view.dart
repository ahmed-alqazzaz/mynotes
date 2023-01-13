import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_services.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: ((context, index) {
        final note = notes[index];
        return ListTile(
            title: Text(
              note.text,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
            trailing: IconButton(
              onPressed: () async {
                final bool shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            ));
      }),
    );
    ;
  }
}

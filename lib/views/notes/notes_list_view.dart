import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/crud/notes_services.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final List<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
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
            ),
            onTap: () => onTap(note));
      }),
    );
  }
}

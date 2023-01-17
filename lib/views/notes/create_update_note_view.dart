import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/dialogs/share_dialog.dart';
import 'package:mynotes/utilities/generics/get_argument.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/auth/auth_user.dart';
import '../../services/cloud/cloud_note.dart';

class CreateUpdateNote extends StatefulWidget {
  const CreateUpdateNote({super.key});

  @override
  State<CreateUpdateNote> createState() => _CreateUpdateNoteState();
}

class _CreateUpdateNoteState extends State<CreateUpdateNote> {
  bool _hasCreatedNote = false;
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textEditingController;
  final AuthUser _user = AuthService.firebase().currentUser!;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _setUpTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  void _textControllerListener() async {
    // in case note has never been created yet
    if (!_hasCreatedNote) {
      _note = await createNewNote();
      return;
    }
    await updateNote();
  }

  Future<CloudNote?> createNewNote() async {
    _hasCreatedNote = true;
    final AuthUser currentUser = AuthService.firebase().currentUser!;
    final text = _textEditingController.text;

    final note =
        await _notesService.createNewNote(ownerUserId: _user.uid, text: text);
    _note = note;
    return note;
  }

  Future<void> updateNote() async {
    final text = _textEditingController.text;
    final oldNote = _note;
    if (oldNote!.text != text) {
      _note = await _notesService.updateNote(
          documentId: oldNote.documentId, text: text);
    }
  }

  @override
  void dispose() {
    if (_textEditingController.text.isEmpty && _note != null) {
      _notesService.deleteNote(documentId: _note!.documentId);
    }
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Note"), actions: [
        IconButton(
            onPressed: () {
              final note = _note;
              if (note?.text != "") {
                Share.share(note!.text);
              } else {
                showCanNotShareEmptyNoteDialog(context);
              }
            },
            icon: const Icon(Icons.share))
      ]),
      body: (BuildContext context) {
        // if it does'nt work, consider conditional assignment
        final noteWidget = context.getArgument<CloudNote>();
        if (noteWidget != null) {
          _hasCreatedNote = true;
          _note = context.getArgument<CloudNote>();
          _textEditingController.text = _note?.text ?? "";
        }

        _setUpTextControllerListener();
        return TextField(
          autofocus: true,
          controller: _textEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "Start Typing Your Notes...",
          ),
        );
      }(context),
    );
  }
}

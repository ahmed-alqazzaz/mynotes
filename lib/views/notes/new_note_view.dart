import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';

import '../../services/auth/auth_user.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _setUpTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  void _textControllerListener() async {
    final existingNote = _note;
    // in case note has never been created yet
    if (existingNote == null) {
      return await createNewNote();
    }
    final id = existingNote.id;
    updateNote(id: id);
  }

  Future<void> createNewNote() async {
    final AuthUser currentUser = AuthService.firebase().currentUser!;
    final DatabaseUser owner =
        await _notesService.getUser(email: currentUser.email!);
    final text = _textEditingController.text;
    final note = await _notesService.createNote(owner: owner, text: text);
    _note = note;
  }

  Future<void> updateNote({required int id}) async {
    final text = _textEditingController.text;
    final oldNote = await _notesService.getNote(id: id);
    if (oldNote.text != text) {
      await _notesService.updateNote(note: oldNote, text: text);
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: () {
        _setUpTextControllerListener();
        return TextField(
          controller: _textEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "Start Typing Your Notes...",
          ),
        );
      }(),
    );
  }
}

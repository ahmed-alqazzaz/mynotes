import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/generics/get_argument.dart';

import '../../services/auth/auth_user.dart';

class CreateUpdateNote extends StatefulWidget {
  const CreateUpdateNote({super.key});

  @override
  State<CreateUpdateNote> createState() => _CreateUpdateNoteState();
}

class _CreateUpdateNoteState extends State<CreateUpdateNote> {
  bool _hasCreatedNote = false;
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
    if (!_hasCreatedNote) {
      _note = await createNewNote();
      await Future.delayed(const Duration(seconds: 5));
      return;
    }
    await updateNote();
  }

  Future<DatabaseNote?> createNewNote() async {
    _hasCreatedNote = true;
    final AuthUser currentUser = AuthService.firebase().currentUser!;
    final DatabaseUser owner =
        await _notesService.getOrCreateUser(email: currentUser.email!);
    final text = _textEditingController.text;

    final note = await _notesService.createNote(owner: owner, text: text);
    _note = note;
    print("a$note");
    return note;
  }

  Future<void> updateNote() async {
    final text = _textEditingController.text;
    final oldNote = _note;
    if (oldNote!.text != text) {
      _note = await _notesService.updateNote(note: oldNote, text: text);
    }
  }

  @override
  void dispose() {
    if (_textEditingController.text.isEmpty && _note != null) {
      _notesService.deleteNote(id: _note!.id);
    }
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: (BuildContext context) {
        // if it does'nt work, consider conditional assignment
        final noteWidget = context.getArgument<DatabaseNote>();
        if (noteWidget != null) {
          _hasCreatedNote = true;
          _note = context.getArgument<DatabaseNote>();
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

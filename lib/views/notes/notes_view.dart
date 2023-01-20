import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
import 'dart:developer' as devtools;

import '../../enums/menu_action.dart';
import '../../services/auth/auth_user.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  MenuAction? selectedMenu;

  late FirebaseCloudStorage _notesService;
  final AuthUser _user = AuthService.firebase().currentUser!;
  //String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Notes"),
          actions: [
            PopupMenuButton<MenuAction>(
              initialValue: selectedMenu,
              onSelected: (MenuAction item) async {
                CloudNote(documentId: '', ownerUserId: '', text: '').x();
                switch (item) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(AuthEventLogout());
                      //final navigator = Navigator.of(context);
                      // await navigator.pushNamedAndRemoveUntil(
                      //   "/login/",
                      //   (route) => false,
                      // );
                    }
                    break;

                  default:
                    devtools.log("TODO");
                }
              },
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<MenuAction>>[
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log out"),
                )
              ],
            )
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: _user.uid),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as List<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) async {
                      final navigator = Navigator.of(context);
                      await navigator.pushNamed("/notes/create-update-note/",
                          arguments: note);
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
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await navigator.pushNamed(
                "/notes/create-update-note/",
              );
            },
            child: const Icon(Icons.add)));
  }
}

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
import 'dart:developer' as devtools;

import '../../enums/menu_action.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  MenuAction? selectedMenu;

  late NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  Future<void> j() async {
    await _notesService.open();
  }

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    //you should remove close
    _notesService.close();
    super.dispose();
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
                final x = await _notesService.getAllNotes();
                print(x);
                switch (item) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();

                      final navigator = Navigator.of(context);
                      await navigator.pushNamedAndRemoveUntil(
                        "/login/",
                        (route) => false,
                      );
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
        body: FutureBuilder(
          future: _notesService.getUser(email: userEmail),
          builder: ((context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteNote(id: note.id);
                              });
                        } else {
                          return const CircularProgressIndicator();
                        }

                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          }),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await navigator.pushNamed(
                "/notes/new-note/",
              );
            },
            child: const Icon(Icons.add)));
  }
}
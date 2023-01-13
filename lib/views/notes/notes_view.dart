import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'dart:developer' as devtools;

import '../../enums/menu_action.dart';

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

                          return ListView.builder(
                            itemCount: allNotes.length,
                            itemBuilder: ((context, index) {
                              final note = allNotes[index];
                              return ListTile(
                                title: Text(
                                  note.text,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                              );
                            }),
                          );
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

Future showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Log Out"),
      content: const Text("Are you sure you want to log out"),
      actions: [
        TextButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop(false);
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop(true);
            },
            child: const Text("Log Out"))
      ],
    ),
  ).then((value) => value ?? false);
}

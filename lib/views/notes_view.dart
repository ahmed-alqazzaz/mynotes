import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  MenuAction? selectedMenu;

  get devtools => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Ui"),
        actions: [
          PopupMenuButton<MenuAction>(
            initialValue: selectedMenu,
            onSelected: (MenuAction item) async {
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
            itemBuilder: ((BuildContext context) =>
                const <PopupMenuEntry<MenuAction>>[
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text("Log out"),
                  )
                ]),
          )
        ],
      ),
    );
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

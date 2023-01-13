import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    content: "Log out",
    title: "Are you sure you want to log out?",
    optionsBuilder: () => {
      "Log Out": true,
      "Cancel": false,
    },
  ).then((value) => value ?? false);
}

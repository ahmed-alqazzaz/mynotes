import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(child: Text(text)),
        actions: [
          Center(
            child: TextButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                },
                child: const Text("Cancel")),
          )
        ],
      );
    },
  );
}

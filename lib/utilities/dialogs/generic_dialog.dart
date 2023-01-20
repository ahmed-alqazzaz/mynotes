import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>(
    {required BuildContext context,
    required String content,
    required String title,
    required DialogOptionBuilder optionsBuilder}) {
  final options = optionsBuilder();
  return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(content),
          title: Text(title),
          actions: options.keys.map((optionTitle) {
            return TextButton(
                onPressed: () {
                  final T value = options[optionTitle];
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(optionTitle));
          }).toList(),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      });
}

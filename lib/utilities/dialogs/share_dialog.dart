import 'package:flutter/cupertino.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCanNotShareEmptyNoteDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    content: "You can't share an empty note!",
    title: "Note can't be empty",
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}

import 'package:flutter/material.dart';
import 'package:project0/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Error occured !',
    content: 'Cannot share an empty note',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

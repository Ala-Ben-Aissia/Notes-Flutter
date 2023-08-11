import 'package:flutter/material.dart';
import 'package:project0/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An error occured!',
    content: text,
    optionsBuilder: () => {
      'OK': null, // (value = options['OK'] = null) => pop(null) = pop();
    },
  );
}

import 'package:flutter/material.dart';
import 'package:project0/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: 'You\'re about to delete this note ...',
    content: 'Are you sure?',
    optionsBuilder: () => {
      'Cancel':
          false, // (value = options['Cancel'] = false) => pop(null) = pop();
      'Delete': true,
    },
  ).then(
    (value) => value ?? false,
  ); // Android back btn
}

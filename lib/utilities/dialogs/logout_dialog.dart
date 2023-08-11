import 'package:flutter/material.dart';
import 'package:project0/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: 'You\'re about to logout ...',
    content: 'Are you sure?',
    optionsBuilder: () => {
      'Cancel':
          false, // (value = options['Cancel'] = false) => pop(null) = pop();
      'Yes': true,
    },
  ).then((value) => value ?? false);
}

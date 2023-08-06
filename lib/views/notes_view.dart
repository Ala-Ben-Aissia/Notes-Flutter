import 'package:flutter/material.dart';
import 'package:project0/services/auth/auth_service.dart';
import '../constants/routes.dart';
import '../enums/menu_actions.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: MenuActions.logout,
                child: Text('Log out'),
              ),
            ],
          )
        ],
      ),
      body: const Text('Note List'),
    );
  }
}

// Logout dialog function

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('You\'re about to Log out ...'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          )
        ],
      );
    },
  ).then((value) =>
      value ??
      false); /* if the showDialog did not return any 
  result ('cancel' and 'yes' onPressed function) THEN it will return false 
  ==> only the two TextButtons are available for pressing (not the body press
  neither the android phones return button)
  */
}

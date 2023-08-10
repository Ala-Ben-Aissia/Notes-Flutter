import 'package:flutter/material.dart';
import 'package:project0/constants/routes.dart';
import 'package:project0/services/auth/auth_service.dart';
import 'package:project0/views/login_view.dart';
import 'package:project0/views/register_view.dart';
import 'package:project0/views/verify_email_view.dart';
import 'package:project0/views/notes/notes_view.dart';

import 'views/notes/create_note.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // to prevent Firebase.initializeApp() being called everytime a btn is pressed
  //                     (in case there is multiple buttons that need the firebase)
  //                     => initialize the Firebase app before everything rendred on the screen
  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          // useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          notesRoute: (context) => const NotesView(),
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          verifyRoute: (context) => const VerifyEmailView(),
          createNoteRoute: (context) => const CreateNote(),
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // once future is performed, call the builder (which will return a view Widget)
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        // snapshot => state of future
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

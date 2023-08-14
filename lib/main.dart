import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project0/constants/routes.dart';
import 'package:project0/services/auth/firebase_auth_provider.dart';
import 'package:project0/services/bloc/auth_bloc.dart';
import 'package:project0/services/bloc/auth_event.dart';
import 'package:project0/services/bloc/auth_state.dart';
import 'package:project0/views/login_view.dart';
import 'package:project0/views/register_view.dart';
import 'package:project0/views/verify_email_view.dart';
import 'package:project0/views/notes/notes_view.dart';
import 'views/notes/create_update_note.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // to prevent Firebase.initializeApp() being called everytime a btn is pressed
  //                     (in case there is multiple buttons that need the firebase)
  //                     => initialize the Firebase app before everything rendred to the screen
  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          // useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
        routes: {
          notesRoute: (context) => const NotesView(),
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          verifyRoute: (context) => const VerifyEmailView(),
          createOrUpdateNoteRoute: (context) => const CreateUpdateNote(),
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize()); // initialize
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }
}

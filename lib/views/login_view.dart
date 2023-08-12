// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project0/services/auth/auth_exceptions.dart';
import 'package:project0/services/auth/auth_service.dart';
import '../constants/routes.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration:
                const InputDecoration(hintText: 'Email:'), // placeholder
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType
                .emailAddress, // add @ to keyboard when typing in the email field
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              hintText: 'Password:',
            ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().logIn(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                if (!mounted) return;
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyRoute,
                    (route) => false,
                  );
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'USER NOT FOUND',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'WRONG PASSWORD',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Account disabled !',
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Not registered yet ? Register here'),
          ),
        ],
      ),
    );
  }
}

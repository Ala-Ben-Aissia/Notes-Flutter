// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;
// import 'package:project0/main.dart';
// import 'package:project0/views/register_view.dart';
// import '../firebase_options.dart';

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
            decoration: const InputDecoration(hintText: 'Password:'),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/notes',
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  devtools.log('USER NOT FOUND!');
                } else {
                  devtools.log('WRONG PASSWORD');
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register',
                (route) => false,
              );
              // Navigator.pushNamed(context, '/register');
            },
            child: const Text('Not registered yet ? Register here'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:project0/services/auth/auth_exceptions.dart';
import 'package:project0/services/auth/auth_service.dart';
import '../constants/routes.dart';
import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerification();
                if (!mounted) return;
                  Navigator.of(context).pushNamed(verifyRoute);
                  // with a back button in case of regret
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'Email Already Taken!',
                );
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'Password should be at least 6 characters!',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'Invalid Email!',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Registration error!',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already registered ? Login here'),
          )
        ],
      ),
    );
  }
}

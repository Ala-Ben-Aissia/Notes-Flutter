import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project0/services/auth/auth_exceptions.dart';
import 'package:project0/services/bloc/auth_event.dart';
import '../services/bloc/auth_bloc.dart';
import '../services/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateRegistering) {
          if (state.exception is EmailAlreadyInUseAuthException) {
            showErrorDialog(
              context,
              'Email is already used',
            );
          } else if (state.exception is WeakPasswordAuthException) {
            showErrorDialog(
              context,
              'Weak password',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            showErrorDialog(
              context,
              'Invalid email',
            );
          } else {
            showErrorDialog(
              context,
              'Failed to register',
            );
          }
        }
      },
      child: Scaffold(
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
                context.read<AuthBloc>().add(
                      AuthEventRegister(
                        email,
                        password,
                      ),
                    );
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventLogout(),
                    );
              },
              child: const Text('Already registered ? Login here'),
            )
          ],
        ),
      ),
    );
  }
}

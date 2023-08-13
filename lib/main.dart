import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project0/constants/routes.dart';
import 'package:project0/services/auth/auth_service.dart';
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
        home: const HomePage(),
        routes: {
          notesRoute: (context) => const NotesView(),
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          verifyRoute: (context) => const VerifyEmailView(),
          createOrUpdateNoteRoute: (context) => const CreateUpdateNote(),
        }),
  );
}

class HomePage extends StatefulWidget {
  // const HomePage({Key? key}) : super(key: key);
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Counter screen'),
          centerTitle: true,
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue =
                state is CounterStateInvalid ? state.invalidValue : '';
            return Column(
              children: [
                Text(
                  'Current value is ${state.value}',
                ),
                Visibility(
                  visible: state is CounterStateInvalid,
                  child: Text('Invalid Value: $invalidValue'),
                ),
                TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: 'Enter a number here'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              IncrementEvent(_controller.text),
                            );
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              DecrementEvent(_controller.text),
                            );
                      },
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  // const CounterStateValid(int value) : super(value);
  const CounterStateValid(super.value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;
  // const CounterStateInvalid({
  //   required this.invalidValue,
  //   required int previousValue,
  // }) : super(previousValue);
  const CounterStateInvalid(
    this.invalidValue,
    super.previousValue, // int value from the parent class CounterState
  );
}

abstract class CounterEvent {
  final String value; // We should handle every type of user input
  CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  IncrementEvent(super.value);
}

class DecrementEvent extends CounterEvent {
  DecrementEvent(super.value);
}

class DivideEvent extends CounterEvent {
  DivideEvent(super.value);
}

// take as input: stream of events and => output: stream of states
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        integer == null
            ? emit(CounterStateInvalid(
                event.value, state.value)) // state.value => previousValue
            : emit(CounterStateValid(state.value + integer));
      },
    );
    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        integer == null
            ? emit(CounterStateInvalid(event.value, state.value))
            : emit(CounterStateValid(state.value - integer));
      },
    );
  }
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       // once future is performed, call the builder (which will return a view Widget)
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         // snapshot => state of future
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = AuthService.firebase().currentUser;
//             if (user != null) {
//               if (user.isEmailVerified) {
//                 return const NotesView();
//               } else {
//                 return const VerifyEmailView();
//               }
//             } else {
//               return const LoginView();
//             }
//           default:
//             return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

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
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder(
        // once future is performed, call the builder (return the entire Column Widget)
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          // snapshot => state of future
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                print('You\'re a verfied user!');
              } else {
                print('You need to verify your email!');
              }
              return const Text('Ahla');
            default:
              return const Text('Done');
          }
        },
      ),
    );
  }
}

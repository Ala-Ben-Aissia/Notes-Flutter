import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable // this class and its subclasses cannot have any mutable field
class AuthUser {
  final String? email; // see email getter in User class (firebase_auth.dart)
  final bool isEmailVerified; // boolean getter
  const AuthUser({required this.email, required this.isEmailVerified});
  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}

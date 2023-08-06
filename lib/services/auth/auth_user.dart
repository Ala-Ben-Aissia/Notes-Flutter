import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable // this class and its subclasses cannot have any mutable field
class AuthUser { // needed in the LoginView function (when checking user?emailVerified)
  final bool isEmailVerified; // boolean getter
  const AuthUser(this.isEmailVerified);
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
  // AuthUser will have the Firebase user propertie (emailVerified) 
}
// user will always have a boolean flag 
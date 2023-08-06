import 'package:project0/services/auth/auth_provider.dart';
import 'package:project0/services/auth/auth_user.dart';
import 'package:project0/services/auth/firebase_auth_provider.dart';

// AuthService is the same as AuthProvider but can have more logic
// AuthService is needed to do some logic between two different services

class AuthService implements AuthProvider {
  final AuthProvider provider;
  AuthService(this.provider);
  factory AuthService.firebase() => AuthService(
        FirebaseAuthProvide(),
      );

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/services/auth/auth_user.dart' show AuthUser;

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> changePassword({
    required String email,
    required String password,
    required String newPassword,
  });
}

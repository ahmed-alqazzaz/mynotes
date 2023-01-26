import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show EmailAuthProvider, FirebaseAuth, FirebaseAuthException, User;

import '../../firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async => await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user == null) {
        throw UserNotLoggedInAuthException();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          throw InvalidEmailAuthException();
        case "weak-password":
          throw WeakPasswordAuthException();
        case "email-already-in-use":
          throw EmailAlreadyInUseAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          throw UserNotFoundAuthException();
        case "invalid-email":
          throw InvalidEmailAuthException();
        case "wrong-password":
          throw WrongPasswordAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> changePassword({
    required String email,
    required String password,
    required String newPassword,
  }) async {
    // in case the user is'nt recently logged in
    User? user = FirebaseAuth.instance.currentUser;
    try {
      user = await user
          ?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: "stevehighly@usa.com",
              password: "A07802529359",
            ),
          )
          .then((value) => value.user);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      switch (e.code) {
        case "user-not-found":
          throw UserNotFoundAuthException();
        case "invalid-email":
          throw InvalidEmailAuthException();
        case "wrong-password":
          throw WrongPasswordAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      log(e.toString());
      throw GenericAuthException();
    }
    try {
      await user!.updatePassword(newPassword);
    } catch (exception) {
      print(exception);
      throw UpdatePasswordAuthException(exception);
    }
  }
}

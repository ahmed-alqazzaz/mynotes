import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Can not log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("user should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test('should be able to initialize in less than in 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("user should be able to get verified", () async {
      await provider.logIn(
        email: "email",
        password: "password",
      );
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("user should be able to log in and out", () async {
      await provider.logIn(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
      await provider.logOut();
    });
  });
}

class NotInitializedException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) {
    if (!_isInitialized) throw NotInitializedException();
    Future.delayed(const Duration(seconds: 2));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    Future.delayed(Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!_isInitialized) throw NotInitializedException();
    if (email == "foobar@gmail.com") throw UserNotFoundAuthException();
    if (password == "foobar") throw NotInitializedException();
    final user = AuthUser(isEmailVerified: false, email: email, uid: "jhhhj");
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    // TODO: implement logOut
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    final newUser = AuthUser(isEmailVerified: true, email: "jjjjjj", uid: "bh");
    _user = newUser;
    return Future.value();
  }

  @override
  Future<void> changePassword(
      {required String email,
      required String password,
      required String newPassword}) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }
}

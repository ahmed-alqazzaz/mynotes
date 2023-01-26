import 'package:equatable/equatable.dart';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
class Loading extends Equatable {
  final String? text;

  const Loading([this.text]);

  @override
  List<Object?> get props => [text];
}

@immutable
abstract class AuthState extends Equatable {
  final Loading? loading;
  const AuthState({required this.loading});
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial({required Loading? loading}) : super(loading: loading);

  @override
  List<Object?> get props => [loading];
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user, {Loading? loading})
      : super(loading: loading);

  @override
  List<Object?> get props => [user, loading];
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({this.exception, Loading? loading})
      : super(loading: loading);

  @override
  List<Object?> get props => [exception, loading];
}

class AuthStateRegisteredNeedsVerification extends AuthState {
  final AuthUser user;
  const AuthStateRegisteredNeedsVerification(this.user, {Loading? loading})
      : super(loading: loading);
  @override
  List<Object?> get props => [user, loading];
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut({this.exception, Loading? loading})
      : super(loading: loading);

  @override
  List<Object?> get props => [exception, loading];
}

class AuthStateChangingPassword extends AuthState {
  final Exception? exception;
  final bool performed;

  const AuthStateChangingPassword(
      {this.exception, required this.performed, Loading? loading})
      : super(loading: loading);

  @override
  List<Object?> get props => [exception, loading, performed];
}

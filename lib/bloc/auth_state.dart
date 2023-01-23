import 'package:equatable/equatable.dart';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState extends Equatable {
  final bool loading;
  const AuthState({required this.loading});
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial({required bool loading}) : super(loading: loading);

  @override
  List<Object?> get props => [loading];
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user, {required bool loading})
      : super(loading: loading);

  @override
  List<Object> get props => [user, loading];
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({this.exception, required bool loading})
      : super(loading: loading);

  @override
  List<Object?> get props => [exception, loading];
}

class AuthStateRegisteredNeedsVerification extends AuthState {
  final AuthUser user;
  const AuthStateRegisteredNeedsVerification(this.user, {required bool loading})
      : super(loading: loading);
  @override
  List<Object> get props => [user, loading];
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut({this.exception, required bool loading})
      : super(loading: loading);

  @override
  List<Object?> get props => [exception, loading];
}

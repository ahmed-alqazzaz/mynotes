import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);

  @override
  List<Object> get props => [user];
}

class AuthStateRegisteredNeedsVerification extends AuthState {
  final AuthUser user;
  const AuthStateRegisteredNeedsVerification(this.user);
  @override
  List<Object> get props => [user];
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

// Failure-related States
@immutable
abstract class AuthStateFailure extends AuthState {
  final Exception exception;
  const AuthStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class AuthStateLoginFailure extends AuthStateFailure {
  const AuthStateLoginFailure(super.exception);
}

class AuthStateLogoutFailure extends AuthStateFailure {
  const AuthStateLogoutFailure(super.exception);
}

class AuthStateRegisterationFailure extends AuthStateFailure {
  const AuthStateRegisterationFailure(super.exception);
}

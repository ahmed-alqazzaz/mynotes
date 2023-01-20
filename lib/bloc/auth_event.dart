import 'package:equatable/equatable.dart';
import 'package:mynotes/services/auth/auth_provider.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister({
    required this.email,
    required this.password,
  });
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogin({
    required this.email,
    required this.password,
  });
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

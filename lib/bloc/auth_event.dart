import 'package:equatable/equatable.dart';
import 'package:mynotes/services/auth/auth_provider.dart';

class UpdateCredentials {
  final String email;
  final String password;
  final String newPassword;

  UpdateCredentials({
    required this.email,
    required this.password,
    required this.newPassword,
  });
}

abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSeekRegisteration extends AuthEvent {
  const AuthEventSeekRegisteration();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister({
    required this.email,
    required this.password,
  });
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogin({
    required this.email,
    required this.password,
  });
}

class AuthEventChangePassword extends AuthEvent {
  final UpdateCredentials? credentials;
  const AuthEventChangePassword({this.credentials});
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

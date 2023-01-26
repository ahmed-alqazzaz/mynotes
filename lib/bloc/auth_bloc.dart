import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/bloc/auth_state.dart';

import 'package:mynotes/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthProvider provider,
    required BuildContext context,
  }) : super(const AuthStateInitial(loading: Loading())) {
    // initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else if (!user.isEmailVerified) {
          emit(AuthStateRegisteredNeedsVerification(user));
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );
    // Register
    on<AuthEventSeekRegisteration>(
      (event, emit) {
        emit(const AuthStateRegistering());
      },
    );
    on<AuthEventRegister>(
      (event, emit) async {
        try {
          emit(const AuthStateRegistering(
              loading: Loading("You're being registered")));
          await provider.createUser(
            email: event.email,
            password: event.password,
          );
          emit(AuthStateRegisteredNeedsVerification(provider.currentUser!));
        } on Exception catch (exception) {
          emit(AuthStateRegistering(exception: exception));
        }
      },
    );
    // login
    on<AuthEventLogin>(
      (event, emit) async {
        try {
          emit(const AuthStateLoggedOut(loading: Loading("Logging in")));
          final user = await provider.logIn(
            email: event.email,
            password: event.password,
          );

          if (!user.isEmailVerified) {
            emit(AuthStateRegisteredNeedsVerification(user));
          } else {
            emit(AuthStateLoggedIn(user));
          }
        } on Exception catch (exception) {
          emit(AuthStateLoggedOut(exception: exception));
        }
      },
    );

    // Logout
    on<AuthEventLogout>(
      (event, emit) async {
        try {
          emit(const AuthStateLoggedOut(loading: Loading("Logging Out")));
          await provider.logOut();
          emit(const AuthStateLoggedOut());
        } on Exception catch (exception) {
          emit(AuthStateLoggedOut(exception: exception));
        }
      },
    );
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        emit(AuthStateRegisteredNeedsVerification(provider.currentUser!,
            loading: const Loading()));
        await provider.sendEmailVerification();
        emit(AuthStateRegisteredNeedsVerification(provider.currentUser!));
      },
    );
    on<AuthEventChangePassword>(
      (event, emit) async {
        if (event.credentials != null) {
          emit(const AuthStateChangingPassword(
              performed: false, loading: Loading("Changing Password...")));
          try {
            await provider.changePassword(
              email: event.credentials!.email,
              password: event.credentials!.password,
              newPassword: event.credentials!.newPassword,
            );
            emit(const AuthStateChangingPassword(performed: true));
          } on Exception catch (exception) {
            emit(AuthStateChangingPassword(
                performed: true, exception: exception));
          }
        } else {
          emit(const AuthStateChangingPassword(performed: false));
        }
      },
    );
  }
}

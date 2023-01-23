import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/bloc/auth_state.dart';

import 'package:mynotes/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthProvider provider,
    required BuildContext context,
  }) : super(const AuthStateInitial(loading: true)) {
    // initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          emit(const AuthStateLoggedOut(loading: false));
        } else if (!user.isEmailVerified) {
          emit(AuthStateRegisteredNeedsVerification(user, loading: false));
        } else {
          emit(AuthStateLoggedIn(user, loading: false));
        }
      },
    );
    // Register
    on<AuthEventSeekRegisteration>(
      (event, emit) {
        emit(const AuthStateRegistering(loading: false));
      },
    );
    on<AuthEventRegister>(
      (event, emit) async {
        try {
          emit(const AuthStateRegistering(loading: true));
          await provider.createUser(
            email: event.email,
            password: event.password,
          );
          emit(AuthStateRegisteredNeedsVerification(provider.currentUser!,
              loading: false));
        } on Exception catch (exception) {
          emit(AuthStateRegistering(exception: exception, loading: false));
        }
      },
    );
    // login
    on<AuthEventLogin>(
      (event, emit) async {
        try {
          emit(const AuthStateLoggedOut(loading: true));
          final user = await provider.logIn(
            email: event.email,
            password: event.password,
          );

          if (!user.isEmailVerified) {
            emit(AuthStateRegisteredNeedsVerification(user, loading: false));
          } else {
            emit(AuthStateLoggedIn(user, loading: false));
          }
        } on Exception catch (exception) {
          emit(AuthStateLoggedOut(exception: exception, loading: false));
        }
      },
    );

    // Logout
    on<AuthEventLogout>(
      (event, emit) async {
        try {
          emit(const AuthStateLoggedOut(loading: true));
          await provider.logOut();
          emit(const AuthStateLoggedOut(loading: false));
        } on Exception catch (exception) {
          emit(AuthStateLoggedOut(exception: exception, loading: false));
        }
      },
    );
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        emit(AuthStateRegisteredNeedsVerification(provider.currentUser!,
            loading: true));
        await provider.sendEmailVerification();
        emit(AuthStateRegisteredNeedsVerification(provider.currentUser!,
            loading: false));
      },
    );
  }
}

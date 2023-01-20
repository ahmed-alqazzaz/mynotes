import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/bloc/auth_state.dart';
import 'package:mynotes/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthProvider provider}) : super(const AuthStateInitial()) {
    // initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        emit(const AuthStateLoading());
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
    on<AuthEventRegister>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          final user = await provider.createUser(
            email: event.email,
            password: event.password,
          );
          emit(AuthStateRegisteredNeedsVerification(user));
        } on Exception catch (exception) {
          emit(AuthStateRegisterationFailure(exception));
        }
      },
    );
    // login
    on<AuthEventLogin>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          final user = await provider.logIn(
            email: event.email,
            password: event.password,
          );
          emit(AuthStateLoggedIn(user));
        } on Exception catch (exception) {
          emit(AuthStateLoginFailure(exception));
        }
      },
    );

    // Logout
    on<AuthEventLogout>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          await provider.logOut();
          emit(const AuthStateLoggedOut());
        } on Exception catch (exception) {
          emit(AuthStateLogoutFailure(exception));
        }
      },
    );
  }
}

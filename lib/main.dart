import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/bloc/auth_state.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';
import 'package:mynotes/views/change_password_view.dart';

import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

import 'package:mynotes/services/auth/auth_service.dart';

import 'bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider(
          create: (context) =>
              AuthBloc(provider: AuthService.firebase(), context: context),
          child: const HomePage(),
        ),
        routes: routes);
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegisteredNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateChangingPassword) {
          if (state.performed == true && state.exception == null) {
            return NotesView();
          } else {
            return ChangePasswordView();
          }
        } else {
          // this should be changed in the future
          return const CircularProgressIndicator();
        }
      },
      listener: (context, state) {
        if (state.loading is Loading) {
          LoadingScreen().show(
              context: context, text: state.loading!.text ?? "Loading ...");
        } else {
          LoadingScreen().hide();
        }
      },
    );
  }
}

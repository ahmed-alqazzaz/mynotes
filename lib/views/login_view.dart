import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import 'package:mynotes/utilities/dialogs/loading_dialog.dart';
import '../bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            return await showErrorDialog(
              context,
              "user not found",
            );
          } else if (state.exception is InvalidEmailAuthException) {
            return await showErrorDialog(
              context,
              "invalid emailll",
            );
          } else if (state.exception is WrongPasswordAuthException) {
            return await showErrorDialog(
              context,
              "Wrong Password",
            );
          } else if (state.exception is GenericAuthException) {
            return await showErrorDialog(
              context,
              "Genercc",
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Enter Your Email Here",
              ),
            ),
            TextField(
              controller: _password,
              autocorrect: false,
              enableSuggestions: false,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Enter Your Password Here",
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                context
                    .read<AuthBloc>()
                    .add(AuthEventLogin(email: email, password: password));
              },
              child: const Text("Login"),
            ),
            TextButton(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventSeekRegisteration());
                },
                child: const Text("Create an account"))
          ],
        ),
      ),
    );
  }
}

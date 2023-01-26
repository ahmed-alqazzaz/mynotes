import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import '../bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  // this will only work in stateful widgets
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
        if (state is AuthStateRegistering) {
          if (state.exception is InvalidEmailAuthException) {
            return await showErrorDialog(
              context,
              "Invalid Email",
            );
          } else if (state.exception is WeakPasswordAuthException) {
            return await showErrorDialog(
              context,
              "Weak Password",
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            return await showErrorDialog(
              context,
              "Email is Already used",
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
            title: const Text("Register"),
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

                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email: email,
                          password: password,
                        ),
                      );
                },
                child: const Text("Register"),
              ),
              TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(
                          const AuthEventLogout(),
                        );
                  },
                  child: const Text("Already Registered?Login Here!"))
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import '../bloc/auth_state.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/dialogs/error_dialog.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _newPassword;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _newPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateChangingPassword) {
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
          } else if (state.exception is UpdatePasswordAuthException) {
            return await showErrorDialog(
              context,
              "G",
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Change Password"),
          ),
          body: Column(
            children: [
              if (state is AuthStateChangingPassword) ...[
                if (state.exception != null) ...[
                  const Text("hhhh"),
                ]
              ],
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
              TextField(
                controller: _newPassword,
                autocorrect: false,
                enableSuggestions: false,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Enter Your New Password Here",
                ),
              ),
              TextButton(
                  onPressed: () {
                    final email = _email.text;
                    final password = _password.text;
                    final newPassword = _newPassword.text;

                    context.read<AuthBloc>().add(
                          AuthEventChangePassword(
                            credentials: UpdateCredentials(
                                email: email,
                                password: password,
                                newPassword: newPassword),
                          ),
                        );
                  },
                  child: const Text("Save Changes"))
            ],
          ),
        );
      },
    );
  }
}

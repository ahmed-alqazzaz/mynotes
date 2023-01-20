import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/auth_bloc.dart';
import 'package:mynotes/bloc/auth_event.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
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

                        try {
                          context.read<AuthBloc>().add(
                              AuthEventLogin(email: email, password: password));
                          // await AuthService.firebase().logIn(
                          //   email: email,
                          //   password: password,
                          // );
                        } on UserNotFoundAuthException {
                          return await showErrorDialog(
                            context,
                            "user not found",
                          );
                        } on InvalidEmailAuthException {
                          return await showErrorDialog(
                            context,
                            "invalid email",
                          );
                        } on WrongPasswordAuthException {
                          return await showErrorDialog(
                            context,
                            "wrong password",
                          );
                        } on GenericAuthException {
                          return await showErrorDialog(
                            context,
                            "another error",
                          );
                        } catch (e) {
                          return await showErrorDialog(
                            context,
                            "another error(${e.toString()})",
                          );
                        }

                        // final navigator = Navigator.of(context);
                        // await navigator.pushNamedAndRemoveUntil(
                        //   "/homepage/",
                        //   (route) => false,
                        // );
                      },
                      child: const Text("Login"),
                    ),
                    TextButton(
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          navigator.pushNamedAndRemoveUntil(
                              "/register/", (route) => false);
                        },
                        child: const Text("Create an account"))
                  ],
                );
              default:
                return const Text("Loading");
            }
          },
        ));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../utilities/show_error_dialog.dart';

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
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
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
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                        } on FirebaseAuthException catch (e) {
                          switch (e.code) {
                            case "user-not-found":
                              return await showErrorDialog(
                                context,
                                "user not found",
                              );
                            case "invalid-email":
                              return await showErrorDialog(
                                context,
                                "invalid-email",
                              );
                            case "wrong-password":
                              return await showErrorDialog(
                                context,
                                "wrong-password",
                              );
                            default:
                              return await showErrorDialog(
                                context,
                                "another error(${e.code})",
                              );
                          }
                        } catch (e) {
                          return await showErrorDialog(
                            context,
                            "another error(${e.toString})",
                          );
                        }
                        final navigator = Navigator.of(context);
                        await navigator.pushNamedAndRemoveUntil(
                          "/homepage/",
                          (route) => false,
                        );
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

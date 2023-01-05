import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../utilities/show_error_dialog.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
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
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        await FirebaseAuth.instance.currentUser
                            ?.sendEmailVerification();
                        final navigator = Navigator.of(context);
                        await navigator.pushNamed(
                          "/verifyemail/",
                        );
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case "invalid-email":
                            return await showErrorDialog(
                              context,
                              "invalid-email",
                            );
                          case "weak-password":
                            return await showErrorDialog(
                              context,
                              "weak-password",
                            );
                          case "email-already-in-use":
                            return await showErrorDialog(
                              context,
                              "email-already-in-use",
                            );
                          default:
                            return await showErrorDialog(
                              context,
                              "another error",
                            );
                        }
                      } catch (e) {
                        return await showErrorDialog(
                          context,
                          "another error(${e.toString()})",
                        );
                      }
                    },
                    child: const Text("Register"),
                  ),
                  TextButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await navigator.pushNamedAndRemoveUntil(
                            "/login/", (route) => false);
                      },
                      child: const Text("Already Registered?Login Here!"))
                ],
              );
            default:
              return const Text("Loading");
          }
        },
      ),
    );
  }
}

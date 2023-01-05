import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
      ),
      body: Column(
        children: [
          const Text("We've sent you an email verification"),
          const Text(
              "If you have'nt received an email yet, click the button below"),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text("Send Email verification"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              final navigator = Navigator.of(context);
              navigator.pushNamedAndRemoveUntil(
                "/register/",
                (route) => false,
              );
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}

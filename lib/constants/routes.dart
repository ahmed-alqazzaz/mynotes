import '../main.dart';
import '../views/login_view.dart';
import '../views/notes/create_update_note_view.dart';
import '../views/register_view.dart';
import '../views/verify_email_view.dart';

final routes = {
  "/login/": (context) => const LoginView(),
  "/register/": (context) => const RegisterView(),
  "/verifyemail/": (context) => const VerifyEmailView(),
  "/homepage/": (context) => const HomePage(),
  "/notes/create-update-note/": (context) => const CreateUpdateNote()
};

//edit homepage and verify email 
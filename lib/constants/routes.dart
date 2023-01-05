import '../main.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/verify_email_view.dart';

final routes = {
  "/login/": (context) => const LoginView(),
  "/register/": (context) => const RegisterView(),
  "VerifyEmail/": (context) => const VerifyEmailView(),
  "/homepage/": (context) => const HomePage(),
};

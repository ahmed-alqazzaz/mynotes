// Generic Exceptions
class GenericAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

// Login Exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Register Exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class UpdatePasswordAuthException implements Exception {
  final dynamic exception;
  const UpdatePasswordAuthException(this.exception);
}

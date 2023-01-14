import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  T? getArgument<T>() => ModalRoute.of(this)?.settings.arguments as T?;
}

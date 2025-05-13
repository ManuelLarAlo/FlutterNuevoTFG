import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/welcome': (context) => const WelcomeScreen(),
  '/register': (context) => const RegisterScreen(),
};

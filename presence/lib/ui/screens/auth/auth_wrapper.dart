import 'package:flutter/material.dart';
import 'package:presencia/main.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const MainNavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}

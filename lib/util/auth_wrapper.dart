import 'package:flutter/material.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/ui/screens/auth/login_screen.dart';
import 'package:paaieds/ui/screens/main_app/main_navigation.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          return const MainNavigation();
        }

        return const LoginScreen();
      },
    );
  }
}

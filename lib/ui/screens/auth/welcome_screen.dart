import 'package:flutter/material.dart';
import 'package:paaieds/ui/screens/auth/login_screen.dart';
import 'package:paaieds/ui/screens/auth/register_screen.dart';
import 'package:paaieds/ui/widgets/util/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Puedes reemplazar este Icon por tu propia imagen o logo
              const Icon(Icons.code_rounded, size: 150, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido a TWORD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Plataforma de aprendizaje asistida por IA para la especialización en desarrollo de software.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 3),
              PrimaryButton(
                text: 'Iniciar Sesión',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Registrarse',
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

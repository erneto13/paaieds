import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/api/gemini.dart';
import 'package:paaieds/ui/screens/auth/register_screen.dart';
import 'package:paaieds/ui/widgets/custom_text_field.dart';
import 'package:paaieds/ui/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PAAIEDS',
                  style: GoogleFonts.montserrat(
                    color: Colors.blueAccent,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Inicia sesión para continuar',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                const CustomTextField(
                  hintText: 'Correo o usuario',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                const CustomTextField(
                  hintText: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'Entrar',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const LearnTestScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: GoogleFonts.montserrat(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Regístrate',
                        style: GoogleFonts.montserrat(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

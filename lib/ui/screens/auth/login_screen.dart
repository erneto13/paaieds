import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/ui/screens/auth/forgot_password_screen.dart';
import 'package:paaieds/ui/screens/auth/register_screen.dart';
import 'package:paaieds/ui/widgets/custom_text_field.dart';
import 'package:paaieds/ui/widgets/primary_button.dart';
import 'package:paaieds/ui/widgets/social_button.dart';
import 'package:paaieds/ui/screens/onboarding/onboarding_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'TWORD',
              textAlign: TextAlign.center,
              style: GoogleFonts.pacifico(
                color: Colors.white,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 60),
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
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            PrimaryButton(text: 'Iniciar Sesión', onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              );
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿No tienes una cuenta? ", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SocialButton(icon: FontAwesomeIcons.instagram, onPressed: () {}),
                SocialButton(icon: FontAwesomeIcons.facebookF, onPressed: () {}),
                SocialButton(icon: FontAwesomeIcons.apple, onPressed: () {}),
                SocialButton(icon: FontAwesomeIcons.twitter, onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/ui/screens/auth/login_screen.dart';
import 'package:paaieds/ui/widgets/custom_text_field.dart';
import 'package:paaieds/ui/widgets/primary_button.dart';
import 'package:paaieds/ui/widgets/social_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              'PAAIEDS',
              textAlign: TextAlign.center,
              style: GoogleFonts.pacifico(
                color: Colors.white,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 40),
            const Row(
              children: [
                Expanded(child: CustomTextField(hintText: 'Nombre', icon: Icons.person_outline)),
                SizedBox(width: 16),
                Expanded(child: CustomTextField(hintText: 'Apellido', icon: Icons.person_outline)),
              ],
            ),
            const SizedBox(height: 20),
            const CustomTextField(hintText: 'Correo', icon: Icons.email_outlined),
            const SizedBox(height: 20),
            const CustomTextField(hintText: 'Contraseña', icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 20),
            const CustomTextField(hintText: 'Confirmar Contraseña', icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 30),
            PrimaryButton(text: 'Registrarse', onPressed: () {
              // TODO: Lógica de registro
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿Ya tienes una cuenta? ", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Inicia Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
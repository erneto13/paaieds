import 'package:flutter/material.dart';
import 'package:paaieds/ui/widgets/custom_text_field.dart';
import 'package:paaieds/ui/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
            const SizedBox(height: 40),
            // Reemplaza este Icon con tu ilustración
            const Icon(Icons.security_rounded, size: 150, color: Colors.white),
            const SizedBox(height: 40),
            const CustomTextField(hintText: 'Correo', icon: Icons.email_outlined),
            const SizedBox(height: 12),
            Text(
              'Al continuar, aceptas los Términos y Condiciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            PrimaryButton(text: 'Recuperar Contraseña', onPressed: (){
              // TODO: Lógica para recuperar contraseña
            })
          ],
        ),
      ),
    );
  }
}
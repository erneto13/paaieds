import 'package:flutter/material.dart';
import 'package:paaieds/core/services/auth_service.dart';
import 'package:paaieds/ui/screens/home/learn_test.dart';
import 'package:paaieds/ui/screens/auth/register_screen.dart';
import 'package:paaieds/ui/widgets/custom_text_field.dart';
import 'package:paaieds/ui/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor completa todos los campos', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final userModel = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (userModel != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LearnTestScreen(user: userModel)),
      );
    } else {
      _showSnackBar('Credenciales incorrectas', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.blueAccent,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(text: 'Entrar', onPressed: _handleLogin),
                const SizedBox(height: 20),
                Row(
                  children: [Expanded(child: Divider(color: Colors.grey[300]))],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.grey[700],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Regístrate',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
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

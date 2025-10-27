import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/screens/auth/register_screen.dart';
import 'package:paaieds/ui/widgets/util/custom_text_field.dart';
import 'package:paaieds/ui/widgets/util/primary_button.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.showInfo(
        context: context,
        message: 'Campos faltantes',
        description: 'Por favor, completa todos los campos.',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (!success) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error de autenticación',
        description:
            authProvider.errorMessage ?? 'Correo o contraseña incorrectos',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: const AssetImage(
                      'assets/images/paaieds_logo.png',
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !authProvider.isLoading,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        icon: Icons.lock_outline,
                        isPassword: !_isPasswordVisible,
                        enabled: !authProvider.isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        onSubmitted: (_) => _handleLogin(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  authProvider.isLoading
                      ? const SpinKitCubeGrid(
                          color: AppColors.lightBlue,
                          size: 50,
                        )
                      : PrimaryButton(
                          text: 'Entrar',
                          onPressed: () => _handleLogin(context),
                        ),
                  const SizedBox(height: 25),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

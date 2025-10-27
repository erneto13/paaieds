import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/ui/screens/auth/login_screen.dart';
import 'package:paaieds/ui/widgets/util/custom_text_field.dart';
import 'package:paaieds/ui/widgets/util/primary_button.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _keyboardVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(onMetricsChanged: _updateKeyboardVisibility),
    );
  }

  void _updateKeyboardVisibility() {
    final visible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (visible != _keyboardVisible) {
      setState(() => _keyboardVisible = visible);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      LifecycleEventHandler(onMetricsChanged: _updateKeyboardVisibility),
    );
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      CustomSnackbar.showInfo(
        context: context,
        message: 'Completa todos los campos',
        description: 'Todos los campos deben ser llenados, intenta de nuevo.',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      CustomSnackbar.showInfo(
        context: context,
        message: 'Correo inválido',
        description: 'Por favor, ingresa un correo válido.',
      );
      return;
    }

    if (password.length < 6) {
      CustomSnackbar.showInfo(
        context: context,
        message: 'Contraseña con pocos caracteres',
        description: 'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    if (password != confirmPassword) {
      CustomSnackbar.showInfo(
        context: context,
        message: 'Contraseñas no coincidentes',
        description: 'Las contraseñas no coinciden, intenta de nuevo.',
      );
      return;
    }

    //usamos el authprovider para registrar
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.registerWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'Cuenta creada',
        description: 'Inicia sesión para usar tu cuenta.',
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      CustomSnackbar.showError(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'Error al registrar',
        description: authProvider.errorMessage ?? 'Intenta más tarde.',
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                top: _keyboardVisible ? 40 : height * 0.08,
                left: 32,
                right: 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: const AssetImage(
                          'assets/images/paaieds_logo.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Completa los campos para registrarte',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 35),
                    SlideInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _firstNameController,
                                  hintText: 'Nombre',
                                  icon: Icons.person_outline,
                                  enabled: !authProvider.isLoading,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _lastNameController,
                                  hintText: 'Apellido',
                                  icon: Icons.person_outline,
                                  enabled: !authProvider.isLoading,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirmar contraseña',
                            icon: Icons.lock_outline,
                            isPassword: !_isConfirmPasswordVisible,
                            enabled: !authProvider.isLoading,
                            onSubmitted: (_) => _handleRegister(context),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: PrimaryButton(
                              text: 'Registrarse',
                              onPressed: () => _handleRegister(context),
                            ),
                          ),
                    const SizedBox(height: 25),
                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final VoidCallback onMetricsChanged;
  LifecycleEventHandler({required this.onMetricsChanged});

  @override
  void didChangeMetrics() {
    onMetricsChanged();
  }
}

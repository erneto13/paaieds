import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/screens/main_app/test_screen.dart';
import 'package:paaieds/ui/widgets/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/gradient_text.dart';
import 'package:paaieds/ui/widgets/snackbar.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/test_preview_card.dart';

class LearnTestScreen extends StatefulWidget {
  final Function(int)? onNavBarTap;
  final int? currentIndex;

  const LearnTestScreen({super.key, this.onNavBarTap, this.currentIndex});

  @override
  State<LearnTestScreen> createState() => _LearnTestScreenState();
}

class _LearnTestScreenState extends State<LearnTestScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _generateTest(BuildContext context) async {
    final topic = _controller.text.trim();

    if (topic.isEmpty) {
      CustomSnackbar.showError(
        context: context,
        message: 'Campo vacío',
        description: 'Por favor, ingresa un tema para generar el test.',
      );
      return;
    }

    //accedemos al testprovider sin escuchar cambios
    final testProvider = Provider.of<TestProvider>(context, listen: false);
    final success = await testProvider.generateTest(topic);

    if (!mounted) return;

    if (!success) {
      CustomSnackbar.showError(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'Error al generar test',
        description: testProvider.errorMessage ?? 'Intenta más tarde.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //obtenemos el usuario del authprovider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Hola, ${user?.displayName ?? 'Usuario'}",
        onProfileTap: () {},
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //seccion superior
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue[50],
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: GradientText(
                        "¿Qué quieres aprender?",
                        gradient: const LinearGradient(
                          colors: [AppColors.deepBlue, AppColors.oceanBlue],
                        ),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildTextField(context),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildGenerateButton(context),
                    ),
                  ],
                ),
              ),
            ),

            //seccion inferior - aqui escuchamos cambios del testprovider
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                child: Center(
                  child: Consumer<TestProvider>(
                    builder: (context, testProvider, child) {
                      //si no hay preguntas generadas, mostrar placeholder
                      if (testProvider.questions.isEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          height: 200,
                          alignment: Alignment.center,
                          child: Text(
                            "Aquí aparecerá tu test generado",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      //si hay preguntas, mostrar el preview
                      return _buildTestPreview(testProvider);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onNavBarTap != null
          ? CustomBottomNavBar(
              currentIndex: widget.currentIndex ?? 0,
              onTap: widget.onNavBarTap!,
            )
          : null,
    );
  }

  Widget _buildTextField(BuildContext context) {
    //escuchamos el testprovider para deshabilitar el campo mientras carga
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return TextField(
          controller: _controller,
          enabled: !testProvider.isLoading,
          style: TextStyle(color: Colors.grey[800]),
          decoration: InputDecoration(
            hintText: "Ejemplo: Signals en Angular",
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.school, color: AppColors.deepBlue),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: AppColors.lightBlue.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: AppColors.highlight,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          onSubmitted: (_) => _generateTest(context),
        );
      },
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        final isLoading = testProvider.isLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _generateTest(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundButtom,
              disabledBackgroundColor: AppColors.lightBlue.withValues(
                alpha: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isLoading ? 0 : 2,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Generando test...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "Generar Test",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTestPreview(TestProvider testProvider) {
    final parsedJson = {
      "topic": testProvider.currentTopic ?? "Test",
      "questions": testProvider.questions
          .map(
            (q) => {
              "question": q.question,
              "options": q.options,
              "answer": q.answer,
            },
          )
          .toList(),
    };

    return SlideInUp(
      key: ValueKey(testProvider.currentTopic),
      duration: const Duration(milliseconds: 400),
      child: TestPreviewCard(
        parsedJson: parsedJson,
        onStartTest: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestScreen()),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

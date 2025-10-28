import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:paaieds/ui/screens/main_app/roadmap/roadmap_screen.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import 'package:paaieds/util/string_formatter.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/screens/main_app/etests/test_result.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/question_card.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  Future<void> _handleSubmit(BuildContext context) async {
    final testProvider = Provider.of<TestProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!testProvider.allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes responder todas las preguntas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = authProvider.currentUser?.uid ?? '';
    final success = await testProvider.evaluateTest(userId);

    if (!context.mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultsScreen(
            topic: testProvider.currentTopic ?? 'Test',
            evaluationResults: testProvider.evaluationResults!,
            onGenerateRoadmap: () async {
              final roadmapProvider = Provider.of<RoadmapProvider>(
                context,
                listen: false,
              );
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              final userId = authProvider.currentUser?.uid;
              if (userId == null) {
                CustomSnackbar.showError(
                  context: context,
                  message: 'Usuario no autenticado',
                  description: 'Por favor, inicia sesión nuevamente.',
                );
                return;
              }

              CustomSnackbar.showInfo(
                context: context,
                message: 'Generando tu roadmap personalizado...',
                description:
                    'Estamos creando un roadmap adaptado a tus necesidades, espera un momento....',
                duration: const Duration(seconds: 10),
              );

              final success = await roadmapProvider.generateRoadmap(
                userId: userId,
                topic: testProvider.currentTopic!,
                level: testProvider.evaluationResults!['level'],
                theta: testProvider.evaluationResults!['theta'],
                percentage: testProvider.evaluationResults!['percentage'],
              );

              if (!context.mounted) return;

              if (success) {
                testProvider.reset();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                  (route) => route.isFirst,
                );
              } else {
                CustomSnackbar.showError(
                  context: context,
                  message: 'Error al generar el roadmap',
                  description:
                      roadmapProvider.errorMessage ??
                      'Inténtalo de nuevo más tarde.',
                );
              }
            },
          ),
        ),
      );
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al evaluar el test',
        description:
            testProvider.errorMessage ?? 'Inténtalo de nuevo más tarde.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            final confirm = await showDialog<bool>(
              context: context,
              barrierColor: Colors.black26,
              builder: (context) => MinimalConfirmDialog(
                title: 'Salir del test',
                content:
                    '¿Seguro que quieres salir? Se perderán tus respuestas.',
                onConfirm: () {
                  // ✅ Limpiar estado al salir
                  testProvider.reset();
                  Navigator.pop(context, true);
                },
              ),
            );
            return confirm ?? false;
          },
          child: Scaffold(
            appBar: CustomAppBar(
              title:
                  'Test: ${testProvider.currentTopic?.toTitleCase() ?? "Test"}',
              isIcon: false,
              customIcon: Icons.close,
              onCustomIconTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  barrierColor: Colors.black26,
                  builder: (context) => MinimalConfirmDialog(
                    title: 'Salir del test',
                    content:
                        '¿Seguro que quieres salir? Se perderán tus respuestas.',
                    onConfirm: () {
                      testProvider.reset();
                      Navigator.pop(context, true);
                    },
                  ),
                );
                if (confirm == true && context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: testProvider.questions.length,
                        itemBuilder: (context, index) {
                          final q = testProvider.questions[index];
                          return QuestionCard(
                            question: q,
                            index: index,
                            onAnswerSelected: (answer) {
                              testProvider.selectAnswer(index, answer);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: testProvider.allAnswered ? 1.0 : 0.4,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              testProvider.allAnswered &&
                                  !testProvider.isLoading
                              ? () => _handleSubmit(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.lightBlue
                                .withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: testProvider.isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SpinKitCircle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Evaluando...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Enviar respuestas",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
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

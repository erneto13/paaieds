import 'package:flutter/material.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/screens/main_app/test_result.dart';
import 'package:paaieds/ui/widgets/confirm_dialog.dart';
import 'package:paaieds/ui/widgets/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/question_card.dart';

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

    //evaluar usando el uid del usuario actual
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
              //aqui generaras el roadmap con la ia
              debugPrint("Generando roadmap...");
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            testProvider.errorMessage ?? 'Error al evaluar el test',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: testProvider.currentTopic ?? "Test",
            isIcon: false,
            customIcon: Icons.close,
            onCustomIconTap: () async {
              await showDialog(
                context: context,
                barrierColor: Colors.black26,
                builder: (context) => MinimalConfirmDialog(
                  title: 'Salir del test',
                  content:
                      '¿Seguro que quieres salir? Se perderán tus respuestas.',
                  onConfirm: () {
                    //limpiar el estado del test al salir
                    testProvider.reset();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
          backgroundColor: Colors.white10,
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
                            //registrar la respuesta en el provider
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
                            testProvider.allAnswered && !testProvider.isLoading
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
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
        );
      },
    );
  }
}

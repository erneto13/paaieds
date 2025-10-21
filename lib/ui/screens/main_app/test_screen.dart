import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/algorithm/irt_service.dart';
import 'package:paaieds/core/models/question.dart';
import 'package:paaieds/ui/screens/main_app/test_result.dart';
import 'package:paaieds/ui/widgets/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/question_card.dart';

class TestScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const TestScreen({super.key, required this.data});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late List<QuestionModel> questions;
  Map<int, String> selectedAnswers = {};
  bool _isEvaluating = false;

  @override
  void initState() {
    super.initState();
    questions = (widget.data["questions"] as List)
        .map((q) => QuestionModel.fromJson(q))
        .toList();
  }

  bool get allAnswered => selectedAnswers.length == questions.length;

  void _handleAnswer(int index, String answer) {
    setState(() {
      selectedAnswers[index] = answer;
    });
  }

  Future<void> _sendAnswers() async {
    if (_isEvaluating) return;

    setState(() => _isEvaluating = true);

    try {
      // Preparar las respuestas con información de corrección
      final responses = questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return {
          'question': q.question,
          'selected': selectedAnswers[i],
          'isCorrect': selectedAnswers[i] == q.answer,
        };
      }).toList();

      // Evaluar con IRT
      final evaluationResults = IRTService.evaluateAbility(
        responses: responses,
      );

      // // Guardar en Firebase (usa el ID del usuario actual)
      // final userId = 'user_123'; // Obtenlo de Firebase Auth

      // await UserProfileService().saveAssessmentResult(
      //   userId: userId,
      //   topicName: widget.data["topic"],
      //   evaluationResults: evaluationResults,
      // );

      // Navegar a la pantalla de resultados
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultsScreen(
            topic: widget.data["topic"],
            evaluationResults: evaluationResults,
            onGenerateRoadmap: () async {
              // Aquí generarás el roadmap con la IA
              _generateRoadmap(widget.data["topic"], evaluationResults);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al evaluar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isEvaluating = false);
      }
    }
  }

  Future<void> _generateRoadmap(
    String topic,
    Map<String, dynamic> evaluationResults,
  ) async {
    // Aquí llamarás a Gemini para generar el roadmap personalizado
    debugPrint(
      "Generando roadmap para $topic con nivel ${evaluationResults['level']}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.data["topic"], onProfileTap: () {}),
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return QuestionCard(
                      question: q,
                      index: index,
                      onAnswerSelected: (answer) =>
                          _handleAnswer(index, answer),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: allAnswered ? 1.0 : 0.4,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: allAnswered && !_isEvaluating
                        ? _sendAnswers
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.lightBlue.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isEvaluating
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
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "Enviar respuestas",
                            style: GoogleFonts.montserrat(
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
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/question.dart';
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

  void _sendAnswers() {
    final result = {
      "topic": widget.data["topic"],
      "answers": questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return {"question": q.question, "selected": selectedAnswers[i]};
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(result);
    debugPrint(jsonString); // lo imprime en consola por ahora

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Respuestas enviadas (ver consola JSON)"),
        backgroundColor: AppColors.deepBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Test: ${widget.data["topic"]}",
        onProfileTap: () {},
      ),
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
                    onPressed: allAnswered ? _sendAnswers : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.lightBlue.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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

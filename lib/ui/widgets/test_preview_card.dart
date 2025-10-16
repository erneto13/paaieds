import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/config/app_colors.dart';

class TestPreviewCard extends StatelessWidget {
  final Map<String, dynamic> parsedJson;
  final VoidCallback onStartTest;

  const TestPreviewCard({
    super.key,
    required this.parsedJson,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    final questions = parsedJson["questions"] as List;
    final topic = parsedJson["topic"];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.oceanBlue, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(topic),
            const SizedBox(height: 16),
            ...questions.take(3).map((q) => _buildQuestionItem(q)),
            if (questions.length > 3) _buildMoreQuestionsText(questions.length),
            const SizedBox(height: 20),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String topic) {
    return Row(
      children: [
        const Icon(Icons.school, color: Colors.white, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            topic,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(dynamic question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              question['question'],
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreQuestionsText(int totalQuestions) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "...y ${totalQuestions - 3} preguntas más",
        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onStartTest,
        icon: const Icon(Icons.play_arrow, color: AppColors.oceanBlue),
        label: Text(
          "Comenzar Test",
          style: GoogleFonts.montserrat(
            color: AppColors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

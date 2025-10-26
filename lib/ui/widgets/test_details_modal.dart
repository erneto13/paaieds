import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/test_results.dart';
import 'package:paaieds/util/string_formatter.dart';

class TestDetailsModal extends StatelessWidget {
  final TestResult result;

  const TestDetailsModal({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDetailCard(
                icon: Icons.military_tech,
                label: 'Estadísticas de tu prueba',
                value:
                    'Nivel: ${result.level}\nRespuestas correctas: ${result.correctAnswers}/${result.totalQuestions}\nPorcentaje de dominio: ${result.percentage.toStringAsFixed(1)}%\nTheta (IRT): ${result.theta.toStringAsFixed(2)}',
                color: _getLevelColor(result.level),
              ),
              if (result.questions != null && result.questions!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildQuestionsSection(),
              ],
              const SizedBox(height: 24),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundButtom.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assessment,
            color: AppColors.backgroundButtom,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            result.topic.toTitleCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    final incorrectQuestions = result.getIncorrectAnswers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Respuestas Incorrectas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        if (incorrectQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Todas las respuestas fueron correctas!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          )
        else
          ...incorrectQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value;
            return _buildQuestionItem(q, index + 1);
          }),
      ],
    );
  }

  Widget _buildQuestionItem(QuestionDetail question, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnswerRow(
            'Tu respuesta:',
            question.userAnswer,
            Colors.red,
            Icons.close,
          ),
          const SizedBox(height: 8),
          _buildAnswerRow(
            'Respuesta correcta:',
            question.correctAnswer,
            Colors.green,
            Icons.check,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(
    String label,
    String answer,
    Color color,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: answer),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Cerrar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Básico':
        return Colors.orange;
      case 'Intermedio':
        return Colors.blue;
      case 'Avanzado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

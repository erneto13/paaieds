import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/question.dart';

class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final ValueChanged<String> onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.lightBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número + pregunta
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.oceanBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Opciones
            Column(
              children: question.options
                  .map((opt) => _buildOption(opt, question, onAnswerSelected))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    String text,
    QuestionModel question,
    ValueChanged<String> onAnswerSelected,
  ) {
    final bool isSelected = text == question.selectedAnswer;

    return GestureDetector(
      onTap: () {
        question.selectedAnswer = text; // guarda directamente en el modelo
        onAnswerSelected(text);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.oceanBlue.withValues(alpha: 0.15)
              : AppColors.oceanBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.oceanBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.oceanBlue : AppColors.deepBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.deepBlue : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

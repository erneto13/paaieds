import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/question.dart';

class QuestionCard extends StatefulWidget {
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
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightBlue.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.index + 1}. ${q.question}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...q.options.map((opt) => _buildOption(opt)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text) {
    final bool isSelected = text == _selectedOption;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedOption = text);
        widget.onAnswerSelected(text);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.oceanBlue.withValues(alpha: 0.2)
              : AppColors.oceanBlue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.oceanBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? AppColors.oceanBlue : AppColors.deepBlue,
          ),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.deepBlue : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

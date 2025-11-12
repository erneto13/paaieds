import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(String) onAnswer;
  final bool isAnswered;
  final String? previousAnswer;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.previousAnswer,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.previousAnswer;
  }

  @override
  Widget build(BuildContext context) {
    final opciones = widget.exercise.data['options'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatement(),
          const SizedBox(height: 24),
          ...opciones.map((option) => _buildOption(option.toString())),
          const SizedBox(height: 28),
          if (!widget.isAnswered) _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildStatement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.exercise.statement,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedOption == option;
    final isDisabled = widget.isAnswered;

    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _selectedOption = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.deepBlue : Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedOption != null && !widget.isAnswered;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canSubmit ? () => widget.onAnswer(_selectedOption!) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit
              ? AppColors.primary
              : Colors.grey.withValues(alpha: 0.3),
          elevation: canSubmit ? 3 : 0,
          shadowColor: canSubmit
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Verificar respuesta',
          style: TextStyle(
            color: canSubmit ? Colors.white : Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

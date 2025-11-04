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
    //si hay una respuesta anterior, establecerla
    _selectedOption = widget.previousAnswer;
  }

  @override
  Widget build(BuildContext context) {
    final opciones = widget.exercise.data['options'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatement(),
        const SizedBox(height: 24),
        ...opciones.map((option) => _buildOption(option.toString())),
        const SizedBox(height: 24),
        if (!widget.isAnswered) _buildSubmitButton(),
      ],
    );
  }

  Widget _buildStatement() {
    return Text(
      widget.exercise.statement,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[900],
        height: 1.4,
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedOption == option;
    final isDisabled = widget.isAnswered;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() => _selectedOption = option);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.backgroundButtom.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.backgroundButtom
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.backgroundButtom
                      : Colors.grey.withValues(alpha: 0.5),
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.backgroundButtom
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.deepBlue : Colors.grey[700],
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
          backgroundColor: AppColors.backgroundButtom,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Verificar Respuesta',
          style: TextStyle(
            color: canSubmit ? Colors.white : Colors.grey[500],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

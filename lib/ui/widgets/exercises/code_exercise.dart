import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';

class CodeExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(String) onAnswer;
  final bool isAnswered;
  final String? previousAnswer;

  const CodeExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.previousAnswer,
  });

  @override
  State<CodeExercise> createState() => _CodeExerciseState();
}

class _CodeExerciseState extends State<CodeExercise> {
  String? _selectedOption;
  bool _showHints = false;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.previousAnswer;
  }

  @override
  Widget build(BuildContext context) {
    final hints = widget.exercise.data['hints'] as List<dynamic>? ?? [];
    final codeSnippet = widget.exercise.data['codeSnippet'] as String? ?? '';
    final outputOptions =
        widget.exercise.data['outputOptions'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatement(),
        const SizedBox(height: 24),

        if (codeSnippet.isNotEmpty) ...[
          _buildCodeSnippet(codeSnippet),
          const SizedBox(height: 24),
        ],

        _buildOutputOptionsTitle(),
        const SizedBox(height: 12),

        ...outputOptions.map((option) => _buildOutputOption(option.toString())),

        const SizedBox(height: 16),

        if (hints.isNotEmpty) ...[
          _buildHintsSection(hints),
          const SizedBox(height: 16),
        ],

        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildStatement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundButtom.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.backgroundButtom.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundButtom.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.code,
              color: AppColors.backgroundButtom,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.exercise.statement,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSnippet(String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.terminal, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Código a analizar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.backgroundButtom.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              //header del editor
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF252526),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5F56),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFBD2E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF27C93F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'code.dart',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              //area de codigo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    color: Color(0xFFD4D4D4),
                    fontSize: 14,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutputOptionsTitle() {
    return Row(
      children: [
        Icon(Icons.output, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          '¿Cuál será la salida de este código?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildOutputOption(String option) {
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
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintsSection(List<dynamic> hints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showHints = !_showHints),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ver pistas (${hints.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[900],
                  ),
                ),
                const Spacer(),
                Icon(
                  _showHints
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.amber[700],
                ),
              ],
            ),
          ),
        ),

        if (_showHints) ...[
          const SizedBox(height: 12),
          ...hints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
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

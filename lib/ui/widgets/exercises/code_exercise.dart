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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
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
          ...outputOptions.map(
            (option) => _buildOutputOption(option.toString()),
          ),

          const SizedBox(height: 20),

          if (hints.isNotEmpty) ...[
            _buildHintsSection(hints),
            const SizedBox(height: 20),
          ],

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

  Widget _buildCodeSnippet(String code) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header tipo editor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF252526),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _buildEditorDot(const Color(0xFFFF5F56)),
                const SizedBox(width: 8),
                _buildEditorDot(const Color(0xFFFFBD2E)),
                const SizedBox(width: 8),
                _buildEditorDot(const Color(0xFF27C93F)),
                const SizedBox(width: 12),
                Text(
                  'main.dart',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // área de código
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
    );
  }

  Widget _buildEditorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildOutputOptionsTitle() {
    return Row(
      children: [
        Icon(Icons.output_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        const Text(
          '¿Cuál será la salida de este código?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOutputOption(String option) {
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
                  fontFamily: 'monospace',
                  height: 1.4,
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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
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
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: hints.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.amber.withValues(alpha: 0.2),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
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
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          crossFadeState: _showHints
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
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

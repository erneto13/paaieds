import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'dart:convert';

class MatchingExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(String) onAnswer;
  final bool isAnswered;
  final String? previousAnswer;

  const MatchingExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.previousAnswer,
  });

  @override
  State<MatchingExercise> createState() => _MatchingExerciseState();
}

class _MatchingExerciseState extends State<MatchingExercise> {
  final Map<String, String> _userMatches = {};
  String? _selectedLeft;

  @override
  void initState() {
    super.initState();
    //cargar respuesta anterior si existe
    if (widget.previousAnswer != null && widget.previousAnswer!.isNotEmpty) {
      try {
        final previousMatches =
            jsonDecode(widget.previousAnswer!) as Map<String, dynamic>;
        _userMatches.addAll(
          previousMatches.map((k, v) => MapEntry(k, v.toString())),
        );
      } catch (e) {
        print('Error al cargar respuesta anterior: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftColumn =
        widget.exercise.data['leftColumn'] as List<dynamic>? ?? [];
    final rightColumn =
        widget.exercise.data['rightColumn'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatement(),
        const SizedBox(height: 24),

        _buildInstructions(),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLeftColumn(leftColumn)),
            const SizedBox(width: 16),
            Expanded(child: _buildRightColumn(rightColumn)),
          ],
        ),

        const SizedBox(height: 24),
        _buildActionButtons(),
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
              Icons.swap_horiz,
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

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selecciona un elemento de la izquierda y luego su pareja de la derecha',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              'Conceptos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildLeftItem(item.toString())),
      ],
    );
  }

  Widget _buildLeftItem(String item) {
    final isSelected = _selectedLeft == item;
    final isMatched = _userMatches.containsKey(item);
    final isDisabled = widget.isAnswered;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                if (isMatched) {
                  //si ya tiene match, quitarlo
                  _userMatches.remove(item);
                }
                _selectedLeft = isSelected ? null : item;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.green.withValues(alpha: 0.1)
              : isSelected
              ? AppColors.backgroundButtom.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isMatched
                ? Colors.green
                : isSelected
                ? AppColors.backgroundButtom
                : Colors.grey.withValues(alpha: 0.3),
            width: isMatched || isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMatched
                    ? Colors.green
                    : isSelected
                    ? AppColors.backgroundButtom
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Icon(
                  isMatched ? Icons.check : Icons.circle,
                  size: 14,
                  color: isMatched || isSelected
                      ? Colors.white
                      : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected || isMatched
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightColumn(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.arrow_back, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              'Descripciones',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildRightItem(item.toString())),
      ],
    );
  }

  Widget _buildRightItem(String item) {
    //verificar si este item ya fue emparejado
    final matchedWith = _userMatches.entries
        .where((entry) => entry.value == item)
        .map((entry) => entry.key)
        .firstOrNull;

    final isMatched = matchedWith != null;
    final isDisabled = widget.isAnswered;

    return GestureDetector(
      onTap: isDisabled || _selectedLeft == null
          ? null
          : () {
              setState(() {
                _userMatches[_selectedLeft!] = item;
                _selectedLeft = null;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.green.withValues(alpha: 0.1)
              : _selectedLeft != null
              ? AppColors.backgroundButtom.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isMatched
                ? Colors.green
                : Colors.grey.withValues(alpha: 0.3),
            width: isMatched ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMatched
                    ? Colors.green
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Icon(
                  isMatched ? Icons.check : Icons.circle,
                  size: 14,
                  color: isMatched ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isMatched ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final leftColumn =
        widget.exercise.data['leftColumn'] as List<dynamic>? ?? [];
    final canSubmit =
        _userMatches.length == leftColumn.length && !widget.isAnswered;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.isAnswered
                ? null
                : () {
                    setState(() {
                      _userMatches.clear();
                      _selectedLeft = null;
                    });
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canSubmit ? _onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundButtom,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Verificar Relaciones',
              style: TextStyle(
                color: canSubmit ? Colors.white : Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    //convertir el mapa a string json para enviar como respuesta
    final answer = jsonEncode(_userMatches);
    widget.onAnswer(answer);
  }
}

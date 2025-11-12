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

  final List<Color> _matchColors = [
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.pink,
    Colors.orange,
    Colors.deepOrange,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
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

  Color? _getMatchColor(String leftItem) {
    if (!_userMatches.containsKey(leftItem)) return null;
    final leftColumn =
        widget.exercise.data['leftColumn'] as List<dynamic>? ?? [];
    final index = leftColumn.indexOf(leftItem);
    if (index == -1) return null;
    return _matchColors[index % _matchColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final leftColumn =
        widget.exercise.data['leftColumn'] as List<dynamic>? ?? [];
    final rightColumn =
        widget.exercise.data['rightColumn'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatement(),
          const SizedBox(height: 20),
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

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selecciona un elemento de la izquierda y luego su pareja de la derecha.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
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
    final matchColor = _getMatchColor(item);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                if (isMatched) _userMatches.remove(item);
                _selectedLeft = isSelected ? null : item;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isMatched
              ? matchColor!.withValues(alpha: 0.1)
              : isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMatched
                ? matchColor!
                : isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isMatched || isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected || isMatched)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            _buildCircleIcon(isMatched, isSelected, matchColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected || isMatched
                      ? FontWeight.w600
                      : FontWeight.w400,
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
    final matchedWith = _userMatches.entries
        .where((entry) => entry.value == item)
        .map((entry) => entry.key)
        .firstOrNull;

    final isMatched = matchedWith != null;
    final isDisabled = widget.isAnswered;
    final matchColor = isMatched ? _getMatchColor(matchedWith!) : null;

    return GestureDetector(
      onTap: isDisabled || _selectedLeft == null
          ? null
          : () {
              setState(() {
                _userMatches[_selectedLeft!] = item;
                _selectedLeft = null;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isMatched
              ? matchColor!.withValues(alpha: 0.1)
              : _selectedLeft != null
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMatched ? matchColor! : Colors.grey.withValues(alpha: 0.3),
            width: isMatched ? 2 : 1,
          ),
          boxShadow: [
            if (isMatched)
              BoxShadow(
                color: matchColor!.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            _buildCircleIcon(isMatched, false, matchColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildCircleIcon(bool isMatched, bool isSelected, Color? color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMatched
            ? color
            : isSelected
            ? AppColors.primary
            : Colors.transparent,
        border: Border.all(
          color: isMatched
              ? color!
              : isSelected
              ? AppColors.primary
              : Colors.grey.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: isMatched || isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
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
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
              backgroundColor: canSubmit
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.3),
              elevation: canSubmit ? 3 : 0,
              shadowColor: canSubmit
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Verificar Relaciones',
              style: TextStyle(
                color: canSubmit ? Colors.white : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    final answer = jsonEncode(_userMatches);
    widget.onAnswer(answer);
  }
}

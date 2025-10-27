import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';

class BlockOrderExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(String) onAnswer;
  final bool isAnswered;

  const BlockOrderExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
  });

  @override
  State<BlockOrderExercise> createState() => _BlockOrderExerciseState();
}

class _BlockOrderExerciseState extends State<BlockOrderExercise> {
  final List<String> _orderedBlocks = [];
  List<String> _availableBlocks = [];

  @override
  void initState() {
    super.initState();
    final blocks = widget.exercise.data['blocks'] as List<dynamic>? ?? [];
    _availableBlocks = List<String>.from(blocks)..shuffle();
  }

  void _onBlockTap(String block) {
    if (widget.isAnswered) return;

    setState(() {
      _orderedBlocks.add(block);
      _availableBlocks.remove(block);
    });
  }

  void _onOrderedBlockTap(String block) {
    if (widget.isAnswered) return;

    setState(() {
      _availableBlocks.add(block);
      _orderedBlocks.remove(block);
    });
  }

  void _onSubmit() {
    final answer = _orderedBlocks.join('|');
    widget.onAnswer(answer);
  }

  void _onReset() {
    if (widget.isAnswered) return;

    setState(() {
      _availableBlocks.addAll(_orderedBlocks);
      _orderedBlocks.clear();
      _availableBlocks.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatement(),
        const SizedBox(height: 24),

        // Zona de bloques ordenados
        _buildOrderedZone(),
        const SizedBox(height: 24),

        // Bloques disponibles
        _buildAvailableBlocks(),
        const SizedBox(height: 24),

        // Botones de acción
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
              Icons.reorder,
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

  Widget _buildOrderedZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tu orden (${_orderedBlocks.length} bloques)',
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
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundButtom.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.backgroundButtom.withValues(alpha: 0.2),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: _orderedBlocks.isEmpty
              ? Center(
                  child: Text(
                    'Arrastra los bloques aquí en el orden correcto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _orderedBlocks.asMap().entries.map((entry) {
                    return _buildOrderedBlock(entry.value, entry.key);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderedBlock(String block, int index) {
    return GestureDetector(
      onTap: () => _onOrderedBlockTap(block),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundButtom,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.backgroundButtom.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundButtom,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                block,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableBlocks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.widgets_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Bloques disponibles',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableBlocks.map((block) {
            return GestureDetector(
              onTap: () => _onBlockTap(block),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Text(
                  block,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final canSubmit =
        _orderedBlocks.isNotEmpty &&
        _availableBlocks.isEmpty &&
        !widget.isAnswered;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.isAnswered ? null : _onReset,
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
              'Verificar Orden',
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
}

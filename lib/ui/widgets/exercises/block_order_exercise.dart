import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';

class BlockOrderExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(String) onAnswer;
  final bool isAnswered;
  final String? previousAnswer;

  const BlockOrderExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.previousAnswer,
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

    if (widget.previousAnswer != null && widget.previousAnswer!.isNotEmpty) {
      _orderedBlocks.addAll(widget.previousAnswer!.split('|'));
      _availableBlocks.removeWhere((b) => _orderedBlocks.contains(b));
    }
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

  void _onReset() {
    if (widget.isAnswered) return;
    setState(() {
      _availableBlocks.addAll(_orderedBlocks);
      _orderedBlocks.clear();
      _availableBlocks.shuffle();
    });
  }

  void _onSubmit() {
    widget.onAnswer(_orderedBlocks.join('|'));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatement(),
          const SizedBox(height: 24),
          _buildOrderedZone(),
          const SizedBox(height: 24),
          _buildAvailableBlocks(),
          const SizedBox(height: 28),
          if (!widget.isAnswered) _buildActionButtons(),
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

  Widget _buildOrderedZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tu orden (${_orderedBlocks.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: _orderedBlocks.isEmpty
              ? Center(
                  child: Text(
                    'Toca los bloques para ordenarlos aquí',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _orderedBlocks
                      .asMap()
                      .entries
                      .map((e) => _buildOrderedBlock(e.value, e.key))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderedBlock(String block, int index) {
    return GestureDetector(
      onTap: () => _onOrderedBlockTap(block),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: Colors.white,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              block,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
            Icon(Icons.widgets_outlined, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Bloques disponibles',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableBlocks
              .map((b) => _buildAvailableBlock(b))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAvailableBlock(String block) {
    return GestureDetector(
      onTap: () => _onBlockTap(block),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          block,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
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
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reiniciar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[800],
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Verificar orden',
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
}

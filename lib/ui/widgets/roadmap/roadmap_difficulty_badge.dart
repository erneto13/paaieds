import 'package:flutter/material.dart';

class RoadmapDifficultyBadge extends StatelessWidget {
  final String difficulty;
  final bool isLocked;

  const RoadmapDifficultyBadge({
    super.key,
    required this.difficulty,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt,
            size: 12,
            color: _getDifficultyColor(difficulty),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDifficulty(difficulty),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getDifficultyColor(difficulty),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
      case 'baja':
        return const Color(0xFF10B981);
      case 'medium':
      case 'media':
        return const Color(0xFFF59E0B);
      case 'high':
      case 'alta':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDifficulty(String difficulty) {
    return difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase();
  }
}

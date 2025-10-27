import 'package:flutter/material.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_difficulty_badge.dart';

class RoadmapSectionHeader extends StatelessWidget {
  final RoadmapSection section;
  final bool isLocked;

  const RoadmapSectionHeader({
    super.key,
    required this.section,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            section.bloomLevel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getBloomColor(section.bloomLevel),
            ),
          ),
        ),
        const SizedBox(width: 8),
        RoadmapDifficultyBadge(
          difficulty: section.baseDifficulty,
          isLocked: isLocked,
        ),
        const Spacer(),
        if (!isLocked && !section.completed)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: _getBloomColor(section.bloomLevel),
              size: 20,
            ),
          ),
      ],
    );
  }

  Color _getBloomColor(String bloomLevel) {
    switch (bloomLevel.toLowerCase()) {
      case 'remember':
      case 'recordar':
        return const Color(0xFF3B82F6);
      case 'understand':
      case 'comprender':
        return const Color(0xFF06B6D4);
      case 'apply':
      case 'aplicar':
        return const Color(0xFF10B981);
      case 'analyze':
      case 'analizar':
        return const Color(0xFFF97316);
      case 'evaluate':
      case 'evaluar':
        return const Color(0xFFEF4444);
      case 'create':
      case 'crear':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';

class RoadmapBadges extends StatelessWidget {
  final String level;
  final int totalSections;

  const RoadmapBadges({
    super.key,
    required this.level,
    required this.totalSections,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildBadge(label: level, color: _getLevelColor(), icon: Icons.star),
        _buildBadge(
          label: '$totalSections secciones',
          color: AppColors.oceanBlue,
          icon: Icons.list,
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor() {
    switch (level.toLowerCase()) {
      case 'basic':
      case 'básico':
        return Colors.orange;
      case 'intermediate':
      case 'intermedio':
        return Colors.blue;
      case 'advanced':
      case 'avanzado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

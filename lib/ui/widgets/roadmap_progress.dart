import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';

class RoadmapProgress extends StatelessWidget {
  final int completedSections;
  final int totalSections;
  final double progressPercentage;

  const RoadmapProgress({
    super.key,
    required this.completedSections,
    required this.totalSections,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Text(
              '$completedSections/$totalSections',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: AppColors.lightBlue.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (progressPercentage < 33) return Colors.orange;
    if (progressPercentage < 66) return Colors.blue;
    return Colors.green;
  }
}

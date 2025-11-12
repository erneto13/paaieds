import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/roadmap_section.dart';

class SectionSummaryCard extends StatelessWidget {
  final RoadmapSection section;
  final double finalTheta;
  final int correctAnswers;
  final int totalQuestions;

  const SectionSummaryCard({
    super.key,
    required this.section,
    required this.finalTheta,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = (correctAnswers / totalQuestions * 100).toInt();
    final improved = accuracy >= 70;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de la sección',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile('Precisión', '$accuracy%'),
                _buildStatTile('Theta', finalTheta.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Objetivos alcanzados:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...section.objectives.map(
              (obj) => Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      obj,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            if (section.objectives.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${section.objectives.length - 3} más...',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: improved
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    improved ? Icons.trending_up : Icons.trending_flat,
                    color: improved ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      improved
                          ? 'Tu nivel ha mejorado, sigue así'
                          : 'Aún puedes reforzar algunos conceptos',
                      style: TextStyle(
                        color: improved
                            ? Colors.green[800]
                            : Colors.orange[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

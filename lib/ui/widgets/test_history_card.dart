// lib/ui/widgets/test_history_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/test_results.dart';

class TestHistoryCard extends StatelessWidget {
  final TestResult result;
  final VoidCallback? onTap;

  const TestHistoryCard({super.key, required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getLevelColor().withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.topic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                _buildLevelBadge(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: '${result.correctAnswers}/${result.totalQuestions}',
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.percent,
                  label: '${result.percentage.toStringAsFixed(1)}%',
                  color: AppColors.deepBlue,
                ),
                const Spacer(),
                Text(
                  _formatDate(result.completedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getLevelColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        result.level,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getLevelColor(),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getLevelColor() {
    switch (result.level) {
      case 'Básico':
        return Colors.orange;
      case 'Intermedio':
        return Colors.blue;
      case 'Avanzado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final df = DateFormat('dd-M-yyyy - hh:mm a');
    return df.format(date);
  }
}

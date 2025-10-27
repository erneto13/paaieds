import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/roadmap_section.dart';

class RoadmapSectionCard extends StatelessWidget {
  final RoadmapSection section;
  final bool isLocked;
  final VoidCallback onTap;

  const RoadmapSectionCard({
    super.key,
    required this.section,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getBorderColor(), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Text(
              section.subtopic,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey[400] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              section.description,
              style: TextStyle(
                fontSize: 14,
                color: isLocked ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetadata(),
            if (section.objectives.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildObjectives(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getBloomColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            section.bloomLevel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getBloomColor(),
            ),
          ),
        ),
        const Spacer(),
        if (section.completed)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 20),
          )
        else if (isLocked)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock, color: Colors.grey[400], size: 20),
          )
        else
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: AppColors.primary,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        _buildMetadataChip(
          icon: Icons.signal_cellular_alt,
          label: _formatDifficulty(section.baseDifficulty),
          color: _getDifficultyColor(),
        ),
        const SizedBox(width: 12),
        _buildMetadataChip(
          icon: Icons.checklist,
          label: '${section.objectives.length} objectives',
          color: AppColors.oceanBlue,
        ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Objectives:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...section.objectives.map(
          (objective) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey[400] : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    objective,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLocked ? Colors.grey[400] : Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getBorderColor() {
    if (section.completed) return Colors.green.withOpacity(0.3);
    if (isLocked) return Colors.grey.withOpacity(0.2);
    return AppColors.primary.withOpacity(0.3);
  }

  Color _getBloomColor() {
    switch (section.bloomLevel.toLowerCase()) {
      case 'remember':
      case 'recordar':
        return Colors.blue;
      case 'understand':
      case 'comprender':
        return Colors.cyan;
      case 'apply':
      case 'aplicar':
        return Colors.green;
      case 'analyze':
      case 'analizar':
        return Colors.orange;
      case 'evaluate':
      case 'evaluar':
        return Colors.deepOrange;
      case 'create':
      case 'crear':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor() {
    switch (section.baseDifficulty.toLowerCase()) {
      case 'low':
      case 'baja':
        return Colors.green;
      case 'medium':
      case 'media':
        return Colors.orange;
      case 'high':
      case 'alta':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDifficulty(String difficulty) {
    return difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase();
  }
}

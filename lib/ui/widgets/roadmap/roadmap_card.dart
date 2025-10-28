import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:intl/intl.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_badges.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_progress.dart';
import 'package:paaieds/util/string_formatter.dart';

class RoadmapCard extends StatelessWidget {
  final Roadmap roadmap;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RoadmapCard({
    super.key,
    required this.roadmap,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              RoadmapBadges(
                level: roadmap.level,
                totalSections: roadmap.totalSections,
              ),
              const SizedBox(height: 8),
              RoadmapProgress(
                completedSections: roadmap.completedSections,
                totalSections: roadmap.totalSections,
                progressPercentage: roadmap.progressPercentage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roadmap.topic.toTitleCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(roadmap.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: Colors.red[400],
          iconSize: 22,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

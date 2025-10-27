import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/ui/widgets/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/roadmap_section_card.dart';
import 'package:provider/provider.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoadmapProvider>(
      builder: (context, roadmapProvider, child) {
        final roadmap = roadmapProvider.currentRoadmap;

        if (roadmap == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "Learning Roadmap",
              onProfileTap: () {},
            ),
            backgroundColor: Colors.white,
            body: const Center(child: Text('No roadmap available')),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: roadmap.topic,
            customIcon: Icons.close,
            onCustomIconTap: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(roadmap),
                _buildProgressBar(roadmap),
                Expanded(child: _buildSectionsList(roadmap.sections)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Roadmap roadmap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepBlue, AppColors.oceanBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Learning Path',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roadmap.topic,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.star,
                label: roadmap.level,
                color: _getLevelColor(roadmap.level),
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.format_list_numbered,
                label: '${roadmap.totalSections} sections',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Roadmap roadmap) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${roadmap.completedSections}/${roadmap.totalSections}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: roadmap.progressPercentage / 100,
              backgroundColor: AppColors.lightBlue.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${roadmap.progressPercentage.toStringAsFixed(0)}% completed',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList(List<RoadmapSection> sections) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index * 100)),
          child: RoadmapSectionCard(
            section: section,
            isLocked: index > 0 && !sections[index - 1].completed,
            onTap: () {
              // TODO: Navigate to exercises for this section
              debugPrint('Section tapped: ${section.subtopic}');
            },
          ),
        );
      },
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Básico':
      case 'Basic':
        return Colors.orange;
      case 'Intermedio':
      case 'Intermediate':
        return Colors.blue;
      case 'Avanzado':
      case 'Advanced':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

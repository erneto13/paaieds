import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/ui/widgets/roadmap_custom_app_bar.dart';
import 'package:paaieds/ui/widgets/roadmap_section_card.dart';
import 'package:paaieds/util/string_formatter.dart';
import 'package:provider/provider.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoadmapProvider>(
      builder: (context, roadmapProvider, child) {
        final roadmap = roadmapProvider.currentRoadmap;

        return Scaffold(
          appBar: RoadmapAppBar(
            topic: roadmap!.topic.toTitleCase(),
            level: roadmap.level,
            completedSections: roadmap.completedSections,
            totalSections: roadmap.totalSections,
            lives: 3,
            onClose: () => Navigator.pop(context),
          ),

          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [Expanded(child: _buildSectionsList(roadmap.sections))],
            ),
          ),
        );
      },
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
}

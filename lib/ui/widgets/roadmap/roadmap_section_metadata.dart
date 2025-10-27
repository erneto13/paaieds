import 'package:flutter/material.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_metadata_chip.dart';

class RoadmapSectionMetadata extends StatelessWidget {
  final RoadmapSection section;
  final bool isLocked;

  const RoadmapSectionMetadata({
    super.key,
    required this.section,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoadmapMetadataChip(
          icon: Icons.checklist,
          label: '${section.objectives.length} objetivos',
          isLocked: isLocked,
        ),
        const SizedBox(width: 8),
        if (section.finalTheta != null)
          RoadmapMetadataChip(
            icon: Icons.analytics,
            label: 'θ: ${section.finalTheta!.toStringAsFixed(2)}',
            isLocked: isLocked,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_connector_line.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_section_node.dart';

class RoadmapPath extends StatelessWidget {
  final List<RoadmapSection> sections;
  final Function(RoadmapSection) onTap;

  const RoadmapPath({super.key, required this.sections, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final isLocked = index > 0 && !sections[index - 1].completed;
        final isEven = index % 2 == 0;

        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index * 100)),
          child: _buildPathNode(
            context,
            section: section,
            index: index,
            isLocked: isLocked,
            isEven: isEven,
            isFirst: index == 0,
            isLast: index == sections.length - 1,
          ),
        );
      },
    );
  }

  Widget _buildPathNode(
    BuildContext context, {
    required RoadmapSection section,
    required int index,
    required bool isLocked,
    required bool isEven,
    required bool isFirst,
    required bool isLast,
  }) {
    return Column(
      children: [
        if (!isFirst)
          RoadmapConnectorLine(
            isCompleted: sections[index - 1].completed,
            isEven: !isEven,
          ),
        Row(
          mainAxisAlignment: isEven
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (!isEven) const Spacer(),
            RoadmapSectionNode(
              section: section,
              isLocked: isLocked,
              isEven: isEven,
              onTap: onTap,
            ),
            if (isEven) const Spacer(),
          ],
        ),
        if (!isLast)
          RoadmapConnectorLine(isCompleted: section.completed, isEven: isEven),
      ],
    );
  }
}

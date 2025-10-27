import 'package:flutter/material.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_complete_badge.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_section_header.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_section_metadata.dart';

class RoadmapSectionNode extends StatelessWidget {
  final RoadmapSection section;
  final bool isLocked;
  final bool isEven;
  final Function(RoadmapSection) onTap;

  const RoadmapSectionNode({
    super.key,
    required this.section,
    required this.isLocked,
    required this.isEven,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : () => onTap(section),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(section, isLocked),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getBloomColor(
                      section.bloomLevel,
                    ).withValues(alpha: isLocked ? 0.1 : 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoadmapSectionHeader(section: section, isLocked: isLocked),
                  const SizedBox(height: 12),
                  _buildTitle(section, isLocked),
                  const SizedBox(height: 8),
                  _buildDescription(section, isLocked),
                  const SizedBox(height: 16),
                  RoadmapSectionMetadata(section: section, isLocked: isLocked),
                ],
              ),
            ),
            if (section.completed)
              const Positioned(
                top: -8,
                right: -8,
                child: RoadmapCompleteBadge(),
              ),
            if (isLocked) _buildLockOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(RoadmapSection section, bool isLocked) {
    return Text(
      section.subtopic,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isLocked ? Colors.white.withValues(alpha: 0.6) : Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription(RoadmapSection section, bool isLocked) {
    return Text(
      section.description,
      style: TextStyle(
        fontSize: 14,
        color: isLocked
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLockOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.lock, color: Colors.grey, size: 32),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(RoadmapSection section, bool isLocked) {
    if (isLocked) {
      return [Colors.grey.shade400, Colors.grey.shade500];
    }

    if (section.completed) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    }

    final baseColor = _getBloomColor(section.bloomLevel);
    return [baseColor, Color.lerp(baseColor, Colors.black, 0.2)!];
  }

  Color _getBloomColor(String bloomLevel) {
    switch (bloomLevel.toLowerCase()) {
      case 'remember':
      case 'recordar':
        return const Color(0xFF3B82F6);
      case 'understand':
      case 'comprender':
        return const Color(0xFF06B6D4);
      case 'apply':
      case 'aplicar':
        return const Color(0xFF10B981);
      case 'analyze':
      case 'analizar':
        return const Color(0xFFF97316);
      case 'evaluate':
      case 'evaluar':
        return const Color(0xFFEF4444);
      case 'create':
      case 'crear':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }
}

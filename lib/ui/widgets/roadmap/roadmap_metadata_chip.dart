import 'package:flutter/material.dart';

class RoadmapMetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLocked;

  const RoadmapMetadataChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isLocked ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withValues(alpha: isLocked ? 0.6 : 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: isLocked ? 0.6 : 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RoadmapConnectorLine extends StatelessWidget {
  final bool isCompleted;
  final bool isEven;

  const RoadmapConnectorLine({
    super.key,
    required this.isCompleted,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [Colors.green, Colors.green.withValues(alpha: 0.6)]
              : [Colors.grey.shade300, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paaieds/core/models/course.dart'; // Si usas el modelo

class ContinueLearningCard extends StatelessWidget {
  final Course course;

  const ContinueLearningCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: course.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            course.chapter,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Autor: ${course.author}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '${(course.progress * 100).toInt()}% completado',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: course.progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
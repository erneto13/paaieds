import 'package:flutter/material.dart';
import 'package:paaieds/core/models/course.dart'; // Si usas el modelo

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3D41),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: course.color.withOpacity(0.3),
              child: Icon(Icons.code_rounded, color: course.color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              course.lessonsInfo,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  // Placeholder para la imagen del autor
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  course.author,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
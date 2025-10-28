import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';

class RoadmapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String topic;
  final String? level;
  final String? subtopic;
  final int? completedSections;
  final int? totalSections;
  final int? lives;
  final VoidCallback onClose;

  const RoadmapAppBar({
    super.key,
    required this.topic,
    this.level,
    this.completedSections,
    this.totalSections,
    this.lives,
    required this.onClose,
    this.subtopic,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Container(
          // Eliminamos la altura fija para que se adapte
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor de texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Mostrar level o subtopic
                    if (level != null)
                      Text(
                        level!,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtopic != null)
                      Text(
                        subtopic!,
                        style: const TextStyle(
                          fontSize: 6,
                          color: Colors.grey,
                        ),
                        softWrap: true,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Indicador de secciones completadas
              if (completedSections != null && totalSections != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.lightBlue.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.format_list_numbered,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$completedSections/$totalSections',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              if (completedSections != null && totalSections != null)
                const SizedBox(width: 12),

              // Vidas
              if (lives != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '$lives',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              if (lives != null) const SizedBox(width: 12),

              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: 26, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

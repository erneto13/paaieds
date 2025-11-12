import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';

class AttachmentNotFoundScreen extends StatelessWidget {
  final PostAttachment attachment;

  const AttachmentNotFoundScreen({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Contenido no disponible',
        customIcon: Icons.arrow_back,
        onCustomIconTap: () => Navigator.pop(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _getTypeLabel(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  attachment.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getMessage(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Volver al foro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeLabel() {
    switch (attachment.type) {
      case PostAttachmentType.roadmap:
        return 'Roadmap no disponible';
      case PostAttachmentType.roadmapSection:
        return 'Sección no disponible';
      case PostAttachmentType.test:
        return 'Test no disponible';
      default:
        return 'Contenido no disponible';
    }
  }

  String _getMessage() {
    switch (attachment.type) {
      case PostAttachmentType.roadmap:
        return 'Este roadmap ha sido eliminado por su autor o ya no está disponible en el sistema.';
      case PostAttachmentType.roadmapSection:
        return 'Esta sección de roadmap ha sido eliminada o el roadmap padre ya no existe.';
      case PostAttachmentType.test:
        return 'Este test diagnóstico ha sido eliminado por su autor o ya no está disponible.';
      default:
        return 'El contenido que intentas ver ya no está disponible.';
    }
  }
}

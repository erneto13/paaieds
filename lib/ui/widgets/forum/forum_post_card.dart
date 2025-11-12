import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/forum_post.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ForumPostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildDescription(),
            if (post.attachment != null) ...[
              const SizedBox(height: 12),
              _buildEnhancedAttachment(),
            ],
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
          backgroundImage: post.authorPhotoUrl != null
              ? NetworkImage(post.authorPhotoUrl!)
              : null,
          child: post.authorPhotoUrl == null
              ? Icon(Icons.person, color: AppColors.deepBlue, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                _formatDate(post.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 20,
            color: Colors.grey[600],
            onPressed: onDelete,
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      post.title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[900],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      post.description,
      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEnhancedAttachment() {
    final attachment = post.attachment!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getAttachmentColor().withValues(alpha: 0.1),
            _getAttachmentColor().withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAttachmentColor().withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getAttachmentColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getAttachmentIcon(),
                  color: _getAttachmentColor(),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAttachmentTypeLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attachment.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _getAttachmentColor(), size: 20),
            ],
          ),
          if (attachment.metadata != null &&
              attachment.metadata!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAttachmentMetadata(attachment),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentMetadata(PostAttachment attachment) {
    final metadata = attachment.metadata!;

    switch (attachment.type) {
      case PostAttachmentType.roadmap:
        return _buildRoadmapMetadata(metadata);
      case PostAttachmentType.roadmapSection:
        return _buildRoadmapSectionMetadata(metadata);
      case PostAttachmentType.test:
        return _buildTestMetadata(metadata);
      case PostAttachmentType.general:
        return _buildGeneralMetadata(metadata);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRoadmapMetadata(Map<String, dynamic> metadata) {
    final level = metadata['level'] as String? ?? 'N/A';
    final progress = metadata['progress'] as double? ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetadataItem(
              icon: Icons.star_outline,
              label: 'Nivel',
              value: level,
              color: _getLevelColor(level),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildMetadataItem(
              icon: Icons.trending_up,
              label: 'Progreso',
              value: '${progress.toInt()}%',
              color: _getProgressColor(progress),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSectionMetadata(Map<String, dynamic> metadata) {
    final bloomLevel = metadata['bloomLevel'] as String? ?? 'N/A';
    final roadmapTopic = metadata['roadmapTopic'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, size: 14, color: Colors.indigo),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'De: $roadmapTopic',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark, size: 14, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(
                  bloomLevel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestMetadata(Map<String, dynamic> metadata) {
    final level = metadata['level'] as String? ?? 'N/A';
    final percentage = metadata['percentage'] as double? ?? 0.0;
    final correctAnswers = metadata['correctAnswers'] as int? ?? 0;
    final totalQuestions = metadata['totalQuestions'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetadataItem(
                  icon: Icons.military_tech,
                  label: 'Nivel',
                  value: level,
                  color: _getLevelColor(level),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildMetadataItem(
                  icon: Icons.percent,
                  label: 'Dominio',
                  value: '${percentage.toInt()}%',
                  color: _getProgressColor(percentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '$correctAnswers/$totalQuestions respuestas correctas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralMetadata(Map<String, dynamic> metadata) {
    final description = metadata['description'] as String? ?? 'Tema abierto';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.forum, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.forum_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${post.replyCount} respuestas',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getAttachmentColor() {
    switch (post.attachment!.type) {
      case PostAttachmentType.roadmap:
        return Colors.blue;
      case PostAttachmentType.roadmapSection:
        return Colors.indigo;
      case PostAttachmentType.test:
        return Colors.green;
      case PostAttachmentType.exercise:
        return Colors.orange;
      case PostAttachmentType.general:
        return Colors.orange;
      case PostAttachmentType.none:
        return Colors.grey;
    }
  }

  IconData _getAttachmentIcon() {
    switch (post.attachment!.type) {
      case PostAttachmentType.roadmap:
        return Icons.map;
      case PostAttachmentType.roadmapSection:
        return Icons.bookmark;
      case PostAttachmentType.test:
        return Icons.quiz;
      case PostAttachmentType.exercise:
        return Icons.fitness_center;
      case PostAttachmentType.general:
        return Icons.chat_bubble_outline;
      case PostAttachmentType.none:
        return Icons.attachment;
    }
  }

  String _getAttachmentTypeLabel() {
    switch (post.attachment!.type) {
      case PostAttachmentType.roadmap:
        return 'Roadmap completo';
      case PostAttachmentType.roadmapSection:
        return 'Sección de roadmap';
      case PostAttachmentType.test:
        return 'Test diagnóstico';
      case PostAttachmentType.exercise:
        return 'Ejercicio';
      case PostAttachmentType.general:
        return 'Discusión general';
      case PostAttachmentType.none:
        return 'Adjunto';
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'básico':
      case 'basico':
        return Colors.orange;
      case 'intermedio':
        return Colors.blue;
      case 'avanzado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 33) return Colors.orange;
    if (percentage < 66) return Colors.blue;
    return Colors.green;
  }

  String _formatDate(dynamic timestamp) {
    DateTime date;
    if (timestamp is DateTime) {
      date = timestamp;
    } else {
      date = timestamp.toDate();
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}

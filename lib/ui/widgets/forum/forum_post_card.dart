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
              _buildAttachment(),
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

  Widget _buildAttachment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAttachmentColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getAttachmentColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getAttachmentColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAttachmentIcon(),
              color: _getAttachmentColor(),
              size: 20,
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
                Text(
                  post.attachment!.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
      case PostAttachmentType.test:
        return Colors.green;
      case PostAttachmentType.exercise:
        return Colors.orange;
      case PostAttachmentType.none:
        return Colors.grey;
    }
  }

  IconData _getAttachmentIcon() {
    switch (post.attachment!.type) {
      case PostAttachmentType.roadmap:
        return Icons.map;
      case PostAttachmentType.test:
        return Icons.quiz;
      case PostAttachmentType.exercise:
        return Icons.fitness_center;
      case PostAttachmentType.none:
        return Icons.attachment;
    }
  }

  String _getAttachmentTypeLabel() {
    switch (post.attachment!.type) {
      case PostAttachmentType.roadmap:
        return 'Roadmap adjunto';
      case PostAttachmentType.test:
        return 'Test adjunto';
      case PostAttachmentType.exercise:
        return 'Ejercicio adjunto';
      case PostAttachmentType.none:
        return 'Adjunto';
    }
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/forum_reply.dart';

class ForumReplyCard extends StatelessWidget {
  final ForumReply reply;
  final VoidCallback? onDelete;

  const ForumReplyCard({super.key, required this.reply, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), const SizedBox(height: 12), _buildContent()],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
          backgroundImage: reply.authorPhotoUrl != null
              ? NetworkImage(reply.authorPhotoUrl!)
              : null,
          child: reply.authorPhotoUrl == null
              ? Icon(Icons.person, color: AppColors.deepBlue, size: 18)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reply.authorName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                _formatDate(reply.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            iconSize: 18,
            color: Colors.red[400],
            onPressed: onDelete,
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      reply.content,
      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
    );
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

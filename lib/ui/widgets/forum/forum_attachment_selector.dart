import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';

class AttachmentSelector extends StatefulWidget {
  final PostAttachment? selectedAttachment;
  final Function(PostAttachment?) onAttachmentSelected;

  const AttachmentSelector({
    super.key,
    required this.selectedAttachment,
    required this.onAttachmentSelected,
  });

  @override
  State<AttachmentSelector> createState() => _AttachmentSelectorState();
}

class _AttachmentSelectorState extends State<AttachmentSelector> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showOptions = !_showOptions),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.selectedAttachment != null
                        ? 'Adjunto: ${widget.selectedAttachment!.title}'
                        : 'Adjuntar contenido (opcional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  _showOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_showOptions) ...[
          const SizedBox(height: 12),
          _buildAttachmentOptions(),
        ],
        if (widget.selectedAttachment != null) ...[
          const SizedBox(height: 12),
          _buildSelectedAttachment(),
        ],
      ],
    );
  }

  Widget _buildAttachmentOptions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildAttachmentOption(
            icon: Icons.map,
            title: 'Adjuntar Roadmap',
            color: Colors.blue,
            onTap: () => _showRoadmapSelector(context),
          ),
          const SizedBox(height: 8),
          _buildAttachmentOption(
            icon: Icons.quiz,
            title: 'Adjuntar Test',
            color: Colors.green,
            onTap: () => _showTestSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAttachment() {
    final attachment = widget.selectedAttachment!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              attachment.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: 18,
            color: Colors.red,
            onPressed: () => widget.onAttachmentSelected(null),
          ),
        ],
      ),
    );
  }

  void _showRoadmapSelector(BuildContext context) {
    final roadmapProvider = Provider.of<RoadmapProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (roadmapProvider.userRoadmaps.isEmpty) {
      roadmapProvider.loadUserRoadmaps(authProvider.currentUser!.uid);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona un Roadmap',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Consumer<RoadmapProvider>(
              builder: (context, provider, child) {
                if (provider.userRoadmaps.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No ti
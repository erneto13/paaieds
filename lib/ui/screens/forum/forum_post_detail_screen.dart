import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/forum_provider.dart';
import 'package:paaieds/ui/widgets/forum/forum_reply_card.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import 'package:provider/provider.dart';

class ForumPostDetailScreen extends StatefulWidget {
  final String postId;

  const ForumPostDetailScreen({super.key, required this.postId});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      forumProvider.loadPost(widget.postId);
    });
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();

    if (content.isEmpty) {
      CustomSnackbar.showError(
        context: context,
        message: 'Campo vacío',
        description: 'Escribe una respuesta antes de enviar',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error de autenticación',
        description: 'Debes iniciar sesión para responder',
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await forumProvider.createReply(
      postId: widget.postId,
      authorId: user.uid,
      authorName: user.displayName,
      authorPhotoUrl: user.photoURL,
      content: content,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      _replyController.clear();
      FocusScope.of(context).unfocus();
      CustomSnackbar.showSuccess(
        context: context,
        message: 'Respuesta publicada',
        description: 'Tu respuesta se ha compartido exitosamente',
      );
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al publicar respuesta',
        description: forumProvider.errorMessage ?? 'Intenta más tarde',
      );
    }
  }

  Future<void> _deleteReply(String replyId) async {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final success = await forumProvider.deleteReply(replyId, widget.postId);

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context: context,
        message: 'Respuesta eliminada',
        description: 'La respuesta se ha eliminado correctamente',
      );
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al eliminar',
        description: forumProvider.errorMessage ?? 'Intenta más tarde',
      );
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    forumProvider.clearCurrentPost();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Publicación",
        isIcon: false,
        customIcon: Icons.arrow_back,
        onCustomIconTap: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.isLoading) {
            return const Center(
              child: SpinKitRing(color: AppColors.primary, size: 60),
            );
          }

          final post = forumProvider.currentPost;

          if (post == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudo cargar la publicación',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: _buildPostHeader(post),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: _buildPostContent(post),
                      ),
                      if (post.attachment != null) ...[
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: _buildAttachment(post),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildRepliesSection(forumProvider),
                    ],
                  ),
                ),
              ),
              _buildReplyInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
          backgroundImage: post.authorPhotoUrl != null
              ? NetworkImage(post.authorPhotoUrl!)
              : null,
          child: post.authorPhotoUrl == null
              ? Icon(Icons.person, color: AppColors.deepBlue, size: 28)
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                _formatDate(post.createdAt),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          post.description,
          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
        ),
      ],
    );
  }

  Widget _buildAttachment(post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getAttachmentColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAttachmentColor().withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getAttachmentColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getAttachmentIcon(),
              color: _getAttachmentColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAttachmentTypeLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.attachment!.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.grey.withValues(alpha: 0.2));
  }

  Widget _buildRepliesSection(forumProvider) {
    final replies = forumProvider.currentPostReplies;
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.forum_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Respuestas (${replies.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (replies.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no hay respuestas',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...replies.asMap().entries.map((entry) {
            final reply = entry.value;
            final isAuthor = currentUser?.uid == reply.authorId;

            return FadeInUp(
              duration: Duration(milliseconds: 400),
              child: ForumReplyCard(
                reply: reply,
                onDelete: isAuthor ? () => _deleteReply(reply.id) : null,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                enabled: !_isSubmitting,
                maxLines: null,
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  hintText: 'Escribe una respuesta...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isSubmitting ? null : _submitReply,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSubmitting
                      ? Colors.grey[300]
                      : AppColors.backgroundButtom,
                  shape: BoxShape.circle,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttachmentColor() {
    final post = Provider.of<ForumProvider>(context).currentPost;
    if (post?.attachment == null) return Colors.grey;

    switch (post!.attachment!.type.toString().split('.').last) {
      case 'roadmap':
        return Colors.blue;
      case 'test':
        return Colors.green;
      case 'exercise':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAttachmentIcon() {
    final post = Provider.of<ForumProvider>(context).currentPost;
    if (post?.attachment == null) return Icons.attachment;

    switch (post!.attachment!.type.toString().split('.').last) {
      case 'roadmap':
        return Icons.map;
      case 'test':
        return Icons.quiz;
      case 'exercise':
        return Icons.fitness_center;
      default:
        return Icons.attachment;
    }
  }

  String _getAttachmentTypeLabel() {
    final post = Provider.of<ForumProvider>(context).currentPost;
    if (post?.attachment == null) return 'Adjunto';

    switch (post!.attachment!.type.toString().split('.').last) {
      case 'roadmap':
        return 'Roadmap adjunto';
      case 'test':
        return 'Test adjunto';
      case 'exercise':
        return 'Ejercicio adjunto';
      default:
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

    return DateFormat('dd MMM yyyy - hh:mm a').format(date);
  }
}

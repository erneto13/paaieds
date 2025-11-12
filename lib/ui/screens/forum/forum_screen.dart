import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/forum_provider.dart';
import 'package:paaieds/ui/screens/forum/forum_post_detail_screen.dart';
import 'package:paaieds/ui/screens/settings/settings_screen.dart';
import 'package:paaieds/ui/widgets/forum/forum_post_card.dart';
import 'package:paaieds/ui/widgets/forum/forum_post_modal.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/util/empty_state.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import 'package:provider/provider.dart';

class ForumScreen extends StatefulWidget {
  final Function(int) onNavBarTap;
  final int currentIndex;

  const ForumScreen({
    super.key,
    required this.onNavBarTap,
    required this.currentIndex,
  });

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      forumProvider.loadPosts();
    });
  }

  Future<void> _showCreatePostModal() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error de autenticación',
        description: 'Debes iniciar sesión para crear publicaciones',
      );
      return;
    }

    await FamilyModalSheet.show<void>(
      contentBackgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostModal(
        onSubmit: (title, description, attachment) async {
          final forumProvider = Provider.of<ForumProvider>(
            context,
            listen: false,
          );

          final success = await forumProvider.createPost(
            authorId: user.uid,
            authorName: user.displayName,
            authorPhotoUrl: user.photoURL,
            title: title,
            description: description,
            attachment: attachment,
          );

          if (!mounted) return;

          Navigator.pop(context);

          if (success) {
            CustomSnackbar.showSuccess(
              context: context,
              message: 'Publicación creada',
              description: 'Tu publicación se ha compartido exitosamente',
            );
          } else {
            CustomSnackbar.showError(
              context: context,
              message: 'Error al crear publicación',
              description: forumProvider.errorMessage ?? 'Intenta más tarde',
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmDeletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => MinimalConfirmDialog(
        title: 'Eliminar publicación',
        content: '¿Estás seguro de que deseas eliminar esta publicación?',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm != true) return;

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final success = await forumProvider.deletePost(postId);

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context: context,
        message: 'Publicación eliminada',
        description: 'La publicación se ha eliminado correctamente',
      );
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al eliminar',
        description: forumProvider.errorMessage ?? 'Intenta más tarde',
      );
    }
  }

  void _navigateToPostDetail(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForumPostDetailScreen(postId: postId)),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onNavBarTap: widget.onNavBarTap,
          currentIndex: widget.currentIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Foro Comunitario",
        onProfileTap: _navigateToSettings,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
            if (forumProvider.isLoading) {
              return const Center(
                child: SpinKitRing(color: AppColors.primary, size: 60),
              );
            }

            if (forumProvider.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyState(
                      icon: Icons.forum_outlined,
                      title: 'Aún no hay publicaciones',
                      message:
                          'Sé el primero en compartir algo con la comunidad',
                    ),
                    const SizedBox(height: 24),
                    _buildCreatePostButton(),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      forumProvider.loadPosts();
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: forumProvider.posts.length,
                      itemBuilder: (context, index) {
                        final post = forumProvider.posts[index];
                        final isAuthor = currentUser?.uid == post.authorId;

                        return FadeInUp(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          child: ForumPostCard(
                            post: post,
                            onTap: () => _navigateToPostDetail(post.id),
                            onDelete: isAuthor
                                ? () => _confirmDeletePost(post.id)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onNavBarTap,
      ),
    );
  }

  Widget _buildBottomBar() {
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
      child: Row(children: [Expanded(child: _buildCreatePostButton())]),
    );
  }

  Widget _buildCreatePostButton() {
    return ElevatedButton.icon(
      onPressed: _showCreatePostModal,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.backgroundButtom,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Nueva Publicación',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_card.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/ui/screens/main_app/roadmap/roadmap_screen.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/util/empty_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:paaieds/config/app_colors.dart';

class RoadmapsListScreen extends StatefulWidget {
  final Function(int) onNavBarTap;
  final int currentIndex;

  const RoadmapsListScreen({
    super.key,
    required this.onNavBarTap,
    required this.currentIndex,
  });

  @override
  State<RoadmapsListScreen> createState() => _RoadmapsListScreenState();
}

class _RoadmapsListScreenState extends State<RoadmapsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadRoadmaps();
  }

  void _loadRoadmaps() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final roadmapProvider = Provider.of<RoadmapProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        roadmapProvider.loadUserRoadmaps(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Mis Roadmaps", onProfileTap: () {}),
      backgroundColor: Colors.white,
      body: Consumer<RoadmapProvider>(
        builder: (context, roadmapProvider, child) {
          if (roadmapProvider.isLoading) {
            return const Center(child: SpinKitRing(color: AppColors.primary));
          }

          if (roadmapProvider.userRoadmaps.isEmpty) {
            return const EmptyState(
              icon: Icons.map_outlined,
              title: 'Aún no hay roadmaps',
              message:
                  'Completa un test diagnóstico para generar\nun roadmap de aprendizaje personalizado',
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cards por fila
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9, // ajustar la altura de la card
              ),
              itemCount: roadmapProvider.userRoadmaps.length,
              itemBuilder: (context, index) {
                final roadmap = roadmapProvider.userRoadmaps[index];
                return RoadmapCard(
                  roadmap: roadmap,
                  onTap: () {
                    roadmapProvider.setCurrentRoadmap(roadmap);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                    );
                  },
                  onDelete: () =>
                      _confirmDelete(context, roadmap, roadmapProvider),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onNavBarTap,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    roadmap,
    roadmapProvider,
  ) async {
    showDialog(
      context: context,
      builder: (_) => MinimalConfirmDialog(
        title: 'Eliminar roadmap',
        content:
            'Eliminarás tu roadmap y con ello todo tu progreso, ¿Deseas continuar?',
        onConfirm: () async {
          Navigator.pop(context);
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );

          final success = await roadmapProvider.deleteRoadmap(
            userId: authProvider.currentUser!.uid,
            roadmapId: roadmap.id,
          );

          if (context.mounted) {
            CustomSnackbar.show(
              context: context,
              message: success
                  ? 'Roadmap eliminado correctamente'
                  : 'Error al eliminar el roadmap',
              description: success
                  ? 'Se ha eliminado el roadmap con éxito.'
                  : 'No se pudo eliminar el roadmap.',
              type: success ? SnackbarType.success : SnackbarType.error,
            );
          }
        },
      ),
    );
  }
}

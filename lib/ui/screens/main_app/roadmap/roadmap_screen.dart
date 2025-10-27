import 'package:flutter/material.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/ui/screens/main_app/exercises/exercise_screen.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_custom_app_bar.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_path.dart';
import 'package:paaieds/util/string_formatter.dart';
import 'package:provider/provider.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoadmapProvider>(
      builder: (context, roadmapProvider, child) {
        final roadmap = roadmapProvider.currentRoadmap;

        return Scaffold(
          appBar: RoadmapAppBar(
            topic: roadmap!.topic.toTitleCase(),
            level: roadmap.level,
            completedSections: roadmap.completedSections,
            totalSections: roadmap.totalSections,
            lives: 3,
            onClose: () => Navigator.pop(context),
          ),

          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RoadmapPath(
                    sections: roadmap.sections,
                    onTap: (section) async {
                      //navegar y esperar el resultado
                      final completed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseScreen(
                            currentTheta: roadmap.initialTheta,
                            section: section,
                          ),
                        ),
                      );

                      //si se completo la seccion, recargar el roadmap
                      if (completed == true && mounted) {
                        print('🔄 Sección completada, recargando roadmap...');
                        final roadmapProvider = Provider.of<RoadmapProvider>(
                          context,
                          listen: false,
                        );
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        //recargar el roadmap desde firebase
                        await roadmapProvider.loadRoadmap(
                          userId: authProvider.currentUser!.uid,
                          roadmapId: roadmap.id,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/util/string_formatter.dart';
import 'package:provider/provider.dart';

class TestResultsScreen extends StatefulWidget {
  final String topic;
  final Map<String, dynamic> evaluationResults;
  final VoidCallback onGenerateRoadmap;

  const TestResultsScreen({
    super.key,
    required this.topic,
    required this.evaluationResults,
    required this.onGenerateRoadmap,
  });

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  bool _isLoading = false;
  bool _roadmapGenerated = false;

  Future<void> _handleGenerateRoadmap() async {
    if (_roadmapGenerated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El roadmap ya fue generado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      widget.onGenerateRoadmap();

      if (mounted) {
        setState(() => _roadmapGenerated = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    final testProvider = Provider.of<TestProvider>(context, listen: false);
    final roadmapProvider = Provider.of<RoadmapProvider>(
      context,
      listen: false,
    );

    if (_roadmapGenerated) {
      testProvider.reset();
      roadmapProvider.clearError();
      return true;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => MinimalConfirmDialog(
        title: 'Salir del diagnóstico',
        content:
            '¿Deseas salir sin generar tu roadmap? Los resultados se guardarán.',
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
      ),
    );

    if (confirm == true) {
      testProvider.reset();
      roadmapProvider.clearError();
    }

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.evaluationResults['level'] as String;
    final percentage = widget.evaluationResults['percentage'] as double;
    final correct = widget.evaluationResults['correctAnswers'] as int;
    final total = widget.evaluationResults['totalQuestions'] as int;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              title: '¡Diagnóstico completado!',
              isIcon: false,
              customIcon: Icons.close,
              onCustomIconTap: _isLoading
                  ? null
                  : () async {
                      final shouldPop = await _onWillPop();
                      if (shouldPop && mounted) {
                        Navigator.of(context).pop();
                      }
                    },
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 400),
                              child: _buildSuccessIcon(),
                            ),
                            const SizedBox(height: 24),
                            FadeInDown(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                '¡Diagnóstico Completado!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FadeInDown(
                              duration: const Duration(milliseconds: 600),
                              child: Text(
                                widget.topic.toTitleCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              duration: const Duration(milliseconds: 700),
                              child: _buildLevelCard(level, percentage),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: _buildStatsCard(correct, total),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 900),
                              child: _buildRecommendationCard(level),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: _buildGenerateButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: const SpinKitRing(
                      color: Colors.white,
                      size: 70,
                      lineWidth: 6,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent.shade100.withValues(alpha: 0.2),
      ),
      child: const Icon(Icons.check_circle, size: 60, color: Colors.blueAccent),
    );
  }

  Widget _buildLevelCard(String level, double percentage) {
    Color levelColor;
    IconData levelIcon;

    switch (level) {
      case 'Básico':
        levelColor = Colors.orange;
        levelIcon = Icons.trending_up;
        break;
      case 'Intermedio':
        levelColor = Colors.blue;
        levelIcon = Icons.star_half;
        break;
      case 'Avanzado':
        levelColor = Colors.green;
        levelIcon = Icons.star;
        break;
      default:
        levelColor = Colors.grey;
        levelIcon = Icons.help;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor, levelColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: levelColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(levelIcon, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Nivel: $level',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}% de dominio',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int correct, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle_outline,
            label: 'Correctas',
            value: correct.toString(),
            color: Colors.green,
          ),
          Container(width: 1, height: 40, color: Colors.grey[400]),
          _buildStatItem(
            icon: Icons.quiz,
            label: 'Total',
            value: total.toString(),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecommendationCard(String level) {
    String recommendation;
    IconData icon;

    switch (level) {
      case 'Básico':
        recommendation =
            'Comenzaremos desde los fundamentos para construir una base sólida.';
        icon = Icons.school;
        break;
      case 'Intermedio':
        recommendation =
            'Reforzaremos conceptos clave y profundizaremos en temas avanzados.';
        icon = Icons.trending_up;
        break;
      case 'Avanzado':
        recommendation =
            'Nos enfocaremos en casos de uso complejos y mejores prácticas.';
        icon = Icons.rocket_launch;
        break;
      default:
        recommendation = 'Crearemos un plan de aprendizaje personalizado.';
        icon = Icons.map;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: (_isLoading || _roadmapGenerated)
            ? null
            : _handleGenerateRoadmap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _roadmapGenerated ? Colors.grey : Colors.blueAccent,
          elevation: 4,
          shadowColor: Colors.blueAccent.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          _roadmapGenerated ? Icons.check : Icons.map,
          color: Colors.white,
        ),
        label: Text(
          _roadmapGenerated ? 'Roadmap Generado' : 'Generar Mi Roadmap',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
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

    final levelColor = _getLevelColor(level);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: RoadmapAppBar(
              topic: 'Resultados del Diagnóstico',
              level: 'sobre ${widget.topic.toTitleCase()}',
              onClose: () async {
                if (_isLoading) return;
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) Navigator.of(context).pop();
              },
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            FadeInDown(
                              duration: const Duration(milliseconds: 400),
                              child: _buildSuccessIcon(levelColor),
                            ),
                            const SizedBox(height: 24),
                            FadeInDown(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                '¡Diagnóstico Completado!',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Has completado tu evaluación sobre ${widget.topic.toTitleCase()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              duration: const Duration(milliseconds: 700),
                              child: _buildLevelDisplay(level, percentage),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: _buildStatsRow(correct, total),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 900),
                              child: _buildRecommendation(level),
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

          // Loading overlay con GIF
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      'assets/sonic.gif',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Básico':
        return Colors.orange;
      case 'Intermedio':
        return Colors.blueAccent;
      case 'Avanzado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSuccessIcon(Color levelColor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: levelColor.withValues(alpha: 0.1),
      ),
      child: Icon(Icons.check_circle_rounded, size: 60, color: levelColor),
    );
  }

  Widget _buildLevelDisplay(String level, double percentage) {
    final levelColor = _getLevelColor(level);
    final levelIcon = switch (level) {
      'Básico' => Icons.trending_up,
      'Intermedio' => Icons.star_half,
      'Avanzado' => Icons.star_rounded,
      _ => Icons.help_outline,
    };

    return Column(
      children: [
        Icon(levelIcon, color: levelColor, size: 40),
        const SizedBox(height: 8),
        Text(
          'Nivel: $level',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: levelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}% de dominio',
          style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int correct, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.check_circle_outline,
            'Correctas',
            correct.toString(),
            Colors.green,
          ),
          Container(width: 1, height: 36, color: Colors.grey[300]),
          _buildStatItem(
            Icons.quiz_outlined,
            'Total',
            total.toString(),
            Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildRecommendation(String level) {
    final (icon, text) = switch (level) {
      'Básico' => (
        Icons.school_rounded,
        'Comenzaremos desde los fundamentos para construir una base sólida.',
      ),
      'Intermedio' => (
        Icons.trending_up_rounded,
        'Reforzaremos conceptos clave y profundizaremos en temas avanzados.',
      ),
      'Avanzado' => (
        Icons.rocket_launch_rounded,
        'Nos enfocaremos en casos complejos y mejores prácticas.',
      ),
      _ => (
        Icons.map_rounded,
        'Crearemos un plan de aprendizaje personalizado.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.blueAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: Icon(
          _roadmapGenerated ? Icons.check_circle_outline : Icons.map_rounded,
          color: Colors.white,
        ),
        label: Text(
          _roadmapGenerated ? 'Roadmap Generado' : 'Generar mi Roadmap',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

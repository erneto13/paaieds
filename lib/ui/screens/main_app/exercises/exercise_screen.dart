import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/exercise_provider.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:paaieds/ui/widgets/exercises/block_order_exercise.dart';
import 'package:paaieds/ui/widgets/exercises/code_exercise.dart';
import 'package:paaieds/ui/widgets/exercises/multiple_choice_exercise.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import 'package:provider/provider.dart';

class ExerciseScreen extends StatefulWidget {
  final RoadmapSection section;
  final double currentTheta;

  const ExerciseScreen({
    super.key,
    required this.section,
    required this.currentTheta,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExercises();
    });
  }

  Future<void> _loadExercises() async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    final success = await exerciseProvider.generateExercisesForSection(
      section: widget.section,
      currentTheta: widget.currentTheta,
    );

    if (!mounted) return;

    if (!success) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al cargar ejercicios',
        description: exerciseProvider.errorMessage ?? 'Intenta más tarde.',
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleNext() async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    if (exerciseProvider.isLastExercise) {
      await _showCompletionDialog();
    } else {
      exerciseProvider.nextExercise();
    }
  }

  Future<void> _showCompletionDialog() async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    final results = exerciseProvider.calculateNewTheta();
    final improved = results['improved'] as bool;
    final newTheta = results['newTheta'] as double;
    final correctAnswers = results['correctAnswers'] as int;
    final totalQuestions = results['totalQuestions'] as int;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CompletionDialog(
        improved: improved,
        newTheta: newTheta,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        onContinue: () async {
          Navigator.pop(context);
          await _completeSection(newTheta);
        },
        onReview: () async {
          Navigator.pop(context);
          await _generateReinforcement();
        },
      ),
    );
  }

  Future<void> _completeSection(double newTheta) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roadmapProvider = Provider.of<RoadmapProvider>(
      context,
      listen: false,
    );

    final success = await roadmapProvider.updateSectionCompletion(
      userId: authProvider.currentUser!.uid,
      sectionId: widget.section.id,
      completed: true,
      finalTheta: newTheta,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context: context,
        message: '¡Sección completada!',
        description: 'Has avanzado en tu roadmap de aprendizaje.',
      );
      Navigator.pop(context, true);
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al guardar progreso',
        description: 'Intenta más tarde.',
      );
    }
  }

  Future<void> _generateReinforcement() async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    // Identificar conceptos fallidos basados en los ejercicios incorrectos
    exerciseProvider.currentProgress!.attempts
        .where((attempt) => !attempt.isCorrect)
        .toList();

    final failedConcepts = widget.section.objectives.take(3).toList();

    CustomSnackbar.showInfo(
      context: context,
      message: 'Generando ejercicios de refuerzo...',
      description: 'Vamos a practicar los conceptos que necesitan más trabajo.',
    );

    final success = await exerciseProvider.generateReinforcementExercises(
      section: widget.section,
      failedConcepts: failedConcepts,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context: context,
        message: 'Ejercicios de refuerzo generados',
        description: '¡Sigue practicando!',
      );
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al generar refuerzo',
        description: exerciseProvider.errorMessage ?? 'Intenta más tarde.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => MinimalConfirmDialog(
            title: 'Salir de los ejercicios',
            content: '¿Seguro que quieres salir? Tu progreso no se guardará.',
            onConfirm: () {
              Navigator.pop(context, true);
            },
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.section.subtopic,
          isIcon: false,
          customIcon: Icons.close,
          onCustomIconTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => MinimalConfirmDialog(
                title: 'Salir de los ejercicios',
                content:
                    '¿Seguro que quieres salir? Tu progreso no se guardará.',
                onConfirm: () {
                  Navigator.pop(context, true);
                },
              ),
            );
            if (confirm == true && mounted) {
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: Colors.white,
        body: Consumer<ExerciseProvider>(
          builder: (context, exerciseProvider, child) {
            if (exerciseProvider.isLoading) {
              return const Center(
                child: SpinKitRing(color: AppColors.primary, size: 60),
              );
            }

            if (exerciseProvider.currentExercise == null) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildProgressBar(exerciseProvider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildExerciseWidget(exerciseProvider),
                        if (exerciseProvider.showingResult) ...[
                          const SizedBox(height: 24),
                          _buildResultCard(exerciseProvider),
                          const SizedBox(height: 24),
                          _buildNavigationButton(exerciseProvider),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(ExerciseProvider provider) {
    final progress =
        (provider.currentExerciseIndex + 1) / provider.exercises.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${provider.currentExerciseIndex + 1} de ${provider.exercises.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightBlue.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWidget(ExerciseProvider provider) {
    final exercise = provider.currentExercise!;

    return FadeIn(
      key: ValueKey(exercise.id),
      duration: const Duration(milliseconds: 400),
      child: _buildExerciseByType(exercise, provider),
    );
  }

  Widget _buildExerciseByType(Exercise exercise, ExerciseProvider provider) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return MultipleChoiceExercise(
          exercise: exercise,
          onAnswer: (answer) {
            provider.submitAnswer(answer);
          },
          isAnswered: provider.showingResult,
        );

      case ExerciseType.blockOrder:
        return BlockOrderExercise(
          exercise: exercise,
          onAnswer: (answer) {
            provider.submitAnswer(answer);
          },
          isAnswered: provider.showingResult,
        );

      case ExerciseType.code:
        return CodeExercise(
          exercise: exercise,
          onAnswer: (answer) {
            provider.submitAnswer(answer);
          },
          isAnswered: provider.showingResult,
        );
    }
  }

  Widget _buildResultCard(ExerciseProvider provider) {
    final isCorrect = provider.isCorrectAnswer;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check : Icons.close,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? '¡Correcto!' : 'Incorrecto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.currentExercise!.feedback,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(ExerciseProvider provider) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            provider.isLastExercise ? Icons.check_circle : Icons.arrow_forward,
            color: Colors.white,
          ),
          label: Text(
            provider.isLastExercise ? 'Finalizar' : 'Siguiente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se pudieron cargar los ejercicios',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  final bool improved;
  final double newTheta;
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onContinue;
  final VoidCallback onReview;

  const _CompletionDialog({
    required this.improved,
    required this.newTheta,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onContinue,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (correctAnswers / totalQuestions * 100).toInt();
    final shouldReview = percentage < 70;

    return FadeIn(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: improved
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  improved ? Icons.trending_up : Icons.trending_flat,
                  size: 48,
                  color: improved ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                improved ? '¡Excelente trabajo!' : '¡Buen esfuerzo!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Respondiste correctamente $correctAnswers de $totalQuestions preguntas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildStatCard(
                'Nivel de conocimiento',
                'θ: ${newTheta.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              _buildStatCard('Precisión', '$percentage%'),
              const SizedBox(height: 24),
              if (shouldReview) ...[
                Text(
                  'Te recomendamos practicar un poco más antes de continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ejercicios de refuerzo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onContinue,
                  child: const Text('Continuar de todos modos'),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

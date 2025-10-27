import 'package:flutter/foundation.dart';
import 'package:paaieds/core/algorithm/irt_service.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/services/exercise_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService();

  List<Exercise> _exercises = [];
  SectionProgress? _currentProgress;
  int _currentExerciseIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showingResult = false;
  bool _isCorrectAnswer = false;

  List<Exercise> get exercises => _exercises;
  SectionProgress? get currentProgress => _currentProgress;
  int get currentExerciseIndex => _currentExerciseIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showingResult => _showingResult;
  bool get isCorrectAnswer => _isCorrectAnswer;
  bool get hasMoreExercises => _currentExerciseIndex < _exercises.length - 1;
  bool get isLastExercise => _currentExerciseIndex == _exercises.length - 1;

  Exercise? get currentExercise {
    if (_exercises.isEmpty || _currentExerciseIndex >= _exercises.length) {
      return null;
    }
    return _exercises[_currentExerciseIndex];
  }

  //genera ejercicios para una sección dada
  Future<bool> generateExercisesForSection({
    required RoadmapSection section,
    required double currentTheta,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exercises = await _exerciseService.generateExercises(
        subtopic: section.subtopic,
        description: section.description,
        currentTheta: currentTheta,
        objectives: section.objectives,
      );

      _currentProgress = SectionProgress(
        sectionId: section.id,
        currentTheta: currentTheta,
        attempts: [],
        correctCount: 0,
        totalAttempts: 0,
      );

      _currentExerciseIndex = 0;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al generar ejercicios: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //registra la respuesta del usuario
  void submitAnswer(String userAnswer) {
    if (currentExercise == null || _currentProgress == null) return;

    final exercise = currentExercise!;
    final isCorrect = _checkAnswer(exercise, userAnswer);

    final attempt = ExerciseAttempt(
      exerciseId: exercise.id,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    _currentProgress = SectionProgress(
      sectionId: _currentProgress!.sectionId,
      currentTheta: _currentProgress!.currentTheta,
      attempts: [..._currentProgress!.attempts, attempt],
      correctCount: _currentProgress!.correctCount + (isCorrect ? 1 : 0),
      totalAttempts: _currentProgress!.totalAttempts + 1,
    );

    _isCorrectAnswer = isCorrect;
    _showingResult = true;
    notifyListeners();
  }

  bool _checkAnswer(Exercise exercise, String userAnswer) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return userAnswer.trim().toLowerCase() ==
            exercise.correctAnswer.trim().toLowerCase();

      case ExerciseType.blockOrder:
        return userAnswer == exercise.correctAnswer;

      case ExerciseType.code:
        final cleanUser = userAnswer.replaceAll(RegExp(r'\s+'), '');
        final cleanCorrect = exercise.correctAnswer.replaceAll(
          RegExp(r'\s+'),
          '',
        );
        return cleanUser.toLowerCase() == cleanCorrect.toLowerCase();
    }
  }

  //avanza al siguiente ejercicio
  void nextExercise() {
    if (hasMoreExercises) {
      _currentExerciseIndex++;
      _showingResult = false;
      _isCorrectAnswer = false;
      notifyListeners();
    }
  }

  //calcula el nuevo theta basado en los intentos realizados
  Map<String, dynamic> calculateNewTheta() {
    if (_currentProgress == null) {
      return {'theta': 0.0, 'improved': false};
    }

    final responses = _currentProgress!.attempts.map((attempt) {
      return {'isCorrect': attempt.isCorrect};
    }).toList();

    if (responses.isEmpty) {
      return {'theta': _currentProgress!.currentTheta, 'improved': false};
    }

    final results = IRTService.evaluateAbility(responses: responses);
    final newTheta = results['theta'] as double;
    final improved = newTheta > _currentProgress!.currentTheta;

    return {
      'oldTheta': _currentProgress!.currentTheta,
      'newTheta': newTheta,
      'improved': improved,
      'percentage': results['percentage'],
      'correctAnswers': results['correctAnswers'],
      'totalQuestions': results['totalQuestions'],
    };
  }

  //genera ejercicios de refuerzo para los conceptos fallidos
  Future<bool> generateReinforcementExercises({
    required RoadmapSection section,
    required List<String> failedConcepts,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentTheta = _currentProgress?.currentTheta ?? 0.0;

      _exercises = await _exerciseService.generateReinforcementExercises(
        subtopic: section.subtopic,
        failedConcepts: failedConcepts,
        currentTheta: currentTheta,
      );

      _currentExerciseIndex = 0;
      _showingResult = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al generar ejercicios de refuerzo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //completa la sección actual
  SectionProgress? completeSection() {
    if (_currentProgress == null) return null;

    final finalProgress = SectionProgress(
      sectionId: _currentProgress!.sectionId,
      currentTheta: calculateNewTheta()['newTheta'],
      attempts: _currentProgress!.attempts,
      correctCount: _currentProgress!.correctCount,
      totalAttempts: _currentProgress!.totalAttempts,
      isCompleted: true,
    );

    return finalProgress;
  }

  void reset() {
    _exercises = [];
    _currentProgress = null;
    _currentExerciseIndex = 0;
    _errorMessage = null;
    _showingResult = false;
    _isCorrectAnswer = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void hideResult() {
    _showingResult = false;
    notifyListeners();
  }
}

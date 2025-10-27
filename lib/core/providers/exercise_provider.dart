import 'package:flutter/foundation.dart';
import 'package:paaieds/core/algorithm/irt_service.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/services/exercise_service.dart';
import 'package:paaieds/core/services/user_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService();
  final UserService _userService = UserService();

  List<Exercise> _exercises = [];
  SectionProgress? _currentProgress;
  int _currentExerciseIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showingResult = false;
  bool _isCorrectAnswer = false;

  String? _currentUserId;
  String? _currentRoadmapId;

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
    required String userId,
    required String roadmapId,
    required RoadmapSection section,
    required double currentTheta,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    _currentRoadmapId = roadmapId;
    notifyListeners();

    try {
      print('VERIFICANDO EJERCICIOS GUARDADOS :: ${section.subtopic}');

      List<Exercise>? savedExercises;
      SectionProgress? savedProgress;

      try {
        savedExercises = await _userService.getSectionExercises(
          uid: userId,
          roadmapId: roadmapId,
          sectionId: section.id,
        );

        savedProgress = await _userService.getSectionProgress(
          uid: userId,
          roadmapId: roadmapId,
          sectionId: section.id,
        );
      } catch (e) {
        print(' PRIMERA VEZ :: SE GENERARÁN EJERCICIOS NUEVOS');
        savedExercises = null;
        savedProgress = null;
      }

      if (savedExercises != null && savedExercises.isNotEmpty) {
        _exercises = savedExercises;
        _currentProgress =
            savedProgress ??
            SectionProgress(
              sectionId: section.id,
              currentTheta: currentTheta,
              attempts: [],
              correctCount: 0,
              totalAttempts: 0,
            );

        _currentExerciseIndex =
            _currentProgress!.totalAttempts < _exercises.length
            ? _currentProgress!.totalAttempts
            : 0;

        print('CARGADOS ${_exercises.length} EJERCICIOS GUARDADOS');
        print(
          'Progreso: ${_currentProgress!.totalAttempts}/${_exercises.length}',
        );
      } else {
        print('Generando nuevos ejercicios para: ${section.subtopic}');

        _exercises = await _exerciseService.generateExercises(
          subtopic: section.subtopic,
          description: section.description,
          currentTheta: currentTheta,
          objectives: section.objectives,
        );

        if (_exercises.isEmpty) {
          throw Exception('No se generaron ejercicios');
        }

        _currentProgress = SectionProgress(
          sectionId: section.id,
          currentTheta: currentTheta,
          attempts: [],
          correctCount: 0,
          totalAttempts: 0,
        );

        _currentExerciseIndex = 0;

        print('Guardando ${_exercises.length} ejercicios...');
        final saved = await _userService.saveSectionExercises(
          uid: userId,
          roadmapId: roadmapId,
          sectionId: section.id,
          exercises: _exercises,
        );

        if (saved) {
          print('Ejercicios guardados exitosamente');
        } else {
          print(
            'No se pudieron guardar los ejercicios (pero se pueden usar)',
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al generar ejercicios: $e';
      print('$_errorMessage');
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

    _saveProgress();

    notifyListeners();
  }

  Future<void> _saveProgress() async {
    if (_currentUserId == null ||
        _currentRoadmapId == null ||
        _currentProgress == null) {
      return;
    }

    try {
      await _userService.saveSectionProgress(
        uid: _currentUserId!,
        roadmapId: _currentRoadmapId!,
        sectionId: _currentProgress!.sectionId,
        progress: _currentProgress!,
      );
    } catch (e) {
      notifyListeners();
    }
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

  void nextExercise() {
    if (hasMoreExercises) {
      _currentExerciseIndex++;
      _showingResult = false;
      _isCorrectAnswer = false;
      notifyListeners();
    }
  }

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

    if (_currentUserId != null && _currentRoadmapId != null) {
      _userService.saveSectionProgress(
        uid: _currentUserId!,
        roadmapId: _currentRoadmapId!,
        sectionId: finalProgress.sectionId,
        progress: finalProgress,
      );
    }

    return finalProgress;
  }

  void reset() {
    _exercises = [];
    _currentProgress = null;
    _currentExerciseIndex = 0;
    _errorMessage = null;
    _showingResult = false;
    _isCorrectAnswer = false;
    _currentUserId = null;
    _currentRoadmapId = null;
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

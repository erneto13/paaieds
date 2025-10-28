import 'dart:convert';

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
  bool _isSectionAlreadyCompleted = false;

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
  bool get isSectionAlreadyCompleted => _isSectionAlreadyCompleted;

  Exercise? get currentExercise {
    if (_exercises.isEmpty || _currentExerciseIndex >= _exercises.length) {
      return null;
    }
    return _exercises[_currentExerciseIndex];
  }

  Future<bool> generateExercisesForSection({
    required String userId,
    required String roadmapId,
    required RoadmapSection section,
    required double currentTheta,
    bool forceRegenerate = false,
  }) async {
    if (userId.isEmpty || roadmapId.isEmpty) {
      _errorMessage = 'IDs de usuario o roadmap inválidos';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _exercises = [];
    _currentProgress = null;
    _currentExerciseIndex = 0;
    _showingResult = false;
    _isCorrectAnswer = false;
    _isSectionAlreadyCompleted = false;

    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    _currentRoadmapId = roadmapId;
    notifyListeners();

    try {
      print('🔍 VERIFICANDO EJERCICIOS GUARDADOS');
      print('   Usuario: $userId');
      print('   Roadmap: $roadmapId');
      print('   Sección: ${section.id} - ${section.subtopic}');

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
        print('ℹ️ PRIMERA VEZ :: SE GENERARÁN EJERCICIOS NUEVOS');
        print('   Razón: $e');
        savedExercises = null;
        savedProgress = null;
      }

      //si existen ejercicios guardados y NO se fuerza regenerar
      if (savedExercises != null &&
          savedExercises.isNotEmpty &&
          !forceRegenerate) {
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

        //verificar si la seccion ya esta completada
        if (savedProgress != null &&
            savedProgress.totalAttempts >= savedExercises.length) {
          print('✅ SECCIÓN YA COMPLETADA ANTERIORMENTE');
          print(
            '   Progreso: ${savedProgress.totalAttempts}/${savedExercises.length}',
          );
          print('   Cargando ejercicios existentes para revisión...');

          _isSectionAlreadyCompleted = true;
          _currentExerciseIndex = 0;
        } else {
          //seccion en progreso - continuar donde se quedo
          _currentExerciseIndex =
              _currentProgress!.totalAttempts < _exercises.length
              ? _currentProgress!.totalAttempts
              : 0;

          print('📚 CONTINUANDO SECCIÓN EN PROGRESO');
          print(
            '   Progreso: ${_currentProgress!.totalAttempts}/${_exercises.length}',
          );
        }

        print('✅ CARGADOS ${_exercises.length} EJERCICIOS GUARDADOS');
      } else {
        //generar nuevos ejercicios
        print('📝 Generando nuevos ejercicios para: ${section.subtopic}');

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

        print('💾 Guardando ${_exercises.length} ejercicios...');
        print(
          '   Path: users/$userId/roadmaps/$roadmapId/exercises/${section.id}',
        );

        final saved = await _userService.saveSectionExercises(
          uid: userId,
          roadmapId: roadmapId,
          sectionId: section.id,
          exercises: _exercises,
        );

        if (saved) {
          print('✅ Ejercicios guardados exitosamente');
        } else {
          print(
            '⚠️ No se pudieron guardar los ejercicios (pero se pueden usar)',
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Error al generar ejercicios: $e';
      print('❌ ERROR CRÍTICO: $_errorMessage');
      print('❌ Stack trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //metodo para reintentar una seccion completada
  Future<bool> retryCompletedSection({
    required String userId,
    required String roadmapId,
    required RoadmapSection section,
    required double currentTheta,
  }) async {
    print('🔄 REINTENTANDO SECCIÓN COMPLETADA');

    //resetear el progreso guardado
    await _userService.saveSectionProgress(
      uid: userId,
      roadmapId: roadmapId,
      sectionId: section.id,
      progress: SectionProgress(
        sectionId: section.id,
        currentTheta: currentTheta,
        attempts: [],
        correctCount: 0,
        totalAttempts: 0,
        isCompleted: false,
      ),
    );

    //regenerar ejercicios
    return await generateExercisesForSection(
      userId: userId,
      roadmapId: roadmapId,
      section: section,
      currentTheta: currentTheta,
      forceRegenerate: true,
    );
  }

  void submitAnswer(String userAnswer) {
    if (currentExercise == null || _currentProgress == null) return;

    //si la seccion ya estaba completada, no permitir enviar respuestas
    if (_isSectionAlreadyCompleted) {
      print('⚠️ No se puede enviar respuesta: sección ya completada');
      return;
    }

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
      print('⚠️ No se puede guardar progreso: IDs nulos');
      return;
    }

    try {
      await _userService.saveSectionProgress(
        uid: _currentUserId!,
        roadmapId: _currentRoadmapId!,
        sectionId: _currentProgress!.sectionId,
        progress: _currentProgress!,
      );
      print('✅ Progreso guardado correctamente');
    } catch (e) {
      print('❌ Error al guardar progreso: $e');
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
        return userAnswer.trim().toLowerCase() ==
            exercise.correctAnswer.trim().toLowerCase();

      case ExerciseType.matching:
        try {
          final userMatches = jsonDecode(userAnswer) as Map<String, dynamic>;
          final correctMatches =
              jsonDecode(exercise.correctAnswer) as Map<String, dynamic>;

          if (userMatches.length != correctMatches.length) return false;

          for (final entry in userMatches.entries) {
            if (correctMatches[entry.key] != entry.value) {
              return false;
            }
          }

          return true;
        } catch (e) {
          print('❌ Error al verificar matching: $e');
          return false;
        }
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
    _isSectionAlreadyCompleted = false;
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

  @override
  void dispose() {
    print('🗑️ ExerciseProvider disposed');
    super.dispose();
  }
}

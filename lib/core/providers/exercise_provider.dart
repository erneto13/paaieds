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
  TheoryContent? _theoryContent;
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
  TheoryContent? get theoryContent => _theoryContent;
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

  Future<bool> generateTheoryContent({
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

    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    _currentRoadmapId = roadmapId;
    notifyListeners();

    try {
      if (!forceRegenerate) {
        final savedTheory = await _userService.getSectionTheory(
          uid: userId,
          roadmapId: roadmapId,
          sectionId: section.id,
        );

        if (savedTheory != null) {
          _theoryContent = savedTheory;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _theoryContent = await _exerciseService.generateTheoryContent(
        subtopic: section.subtopic,
        description: section.description,
        objectives: section.objectives,
        currentTheta: currentTheta,
      );

      if (_theoryContent == null) {
        throw Exception('No se pudo generar el contenido teórico');
      }

      final saved = await _userService.saveSectionTheory(
        uid: userId,
        roadmapId: roadmapId,
        sectionId: section.id,
        theoryContent: _theoryContent!,
      );

      if (!saved) {}

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al generar contenido teórico: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

    if (_theoryContent == null) {
      _errorMessage = 'Debe generar la teoría primero';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    _currentRoadmapId = roadmapId;
    notifyListeners();

    try {
      final (savedExercises, savedProgress) = await _loadSavedData(
        userId: userId,
        roadmapId: roadmapId,
        sectionId: section.id,
      );

      if (savedExercises != null &&
          savedExercises.isNotEmpty &&
          !forceRegenerate) {
        _handleExistingExercises(
          savedExercises,
          savedProgress,
          section.id,
          currentTheta,
        );
      } else {
        await _generateAndSaveNewExercises(
          section: section,
          currentTheta: currentTheta,
          userId: userId,
          roadmapId: roadmapId,
        );
      }

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

  Future<bool> retryCompletedSection({
    required String userId,
    required String roadmapId,
    required RoadmapSection section,
    required double currentTheta,
  }) async {
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

    final theorySuccess = await generateTheoryContent(
      userId: userId,
      roadmapId: roadmapId,
      section: section,
      currentTheta: currentTheta,
      forceRegenerate: true,
    );

    if (!theorySuccess) return false;

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

    if (_isSectionAlreadyCompleted) {
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
      theoryReviewed: _currentProgress!.theoryReviewed,
    );

    _isCorrectAnswer = isCorrect;
    _showingResult = true;

    _saveProgress();
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
          return false;
        }
    }
  }

  void nextExercise() {
    if (hasMoreExercises) {
      _currentExerciseIndex++;

      if (_isSectionAlreadyCompleted && _currentProgress != null) {
        final currentAttempt = _currentProgress!.attempts.firstWhere(
          (a) => a.exerciseId == currentExercise!.id,
          orElse: () => _currentProgress!.attempts[_currentExerciseIndex],
        );
        _showingResult = true;
        _isCorrectAnswer = currentAttempt.isCorrect;
      } else {
        _showingResult = false;
        _isCorrectAnswer = false;
      }

      notifyListeners();
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
      theoryReviewed: true,
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

  String? getCurrentExerciseUserAnswer() {
    if (_currentProgress == null || currentExercise == null) return null;

    try {
      final attempt = _currentProgress!.attempts.firstWhere(
        (a) => a.exerciseId == currentExercise!.id,
      );
      return attempt.userAnswer;
    } catch (e) {
      return null;
    }
  }

  bool? isCurrentExerciseCorrect() {
    if (_currentProgress == null || currentExercise == null) return null;

    try {
      final attempt = _currentProgress!.attempts.firstWhere(
        (a) => a.exerciseId == currentExercise!.id,
      );
      return attempt.isCorrect;
    } catch (e) {
      return null;
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

  int getCorrectAnswersForSection() {
    return _currentProgress?.correctCount ?? 0;
  }

  int getIncorrectAnswersForSection() {
    if (_currentProgress == null) return 0;
    return _currentProgress!.totalAttempts - _currentProgress!.correctCount;
  }

  int getTotalQuestionsForSection() {
    return _exercises.length;
  }

  void reset() {
    _exercises = [];
    _theoryContent = null;
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

  Future<(List<Exercise>?, SectionProgress?)> _loadSavedData({
    required String userId,
    required String roadmapId,
    required String sectionId,
  }) async {
    try {
      final exercises = await _userService.getSectionExercises(
        uid: userId,
        roadmapId: roadmapId,
        sectionId: sectionId,
      );

      final progress = await _userService.getSectionProgress(
        uid: userId,
        roadmapId: roadmapId,
        sectionId: sectionId,
      );

      return (exercises, progress);
    } catch (e) {
      return (null, null);
    }
  }

  void _handleExistingExercises(
    List<Exercise> savedExercises,
    SectionProgress? savedProgress,
    String sectionId,
    double currentTheta,
  ) {
    _exercises = savedExercises;
    _currentProgress =
        savedProgress ??
        SectionProgress(
          sectionId: sectionId,
          currentTheta: currentTheta,
          attempts: [],
          correctCount: 0,
          totalAttempts: 0,
          theoryReviewed: false,
        );

    if (savedProgress != null &&
        savedProgress.totalAttempts >= savedExercises.length) {
      _isSectionAlreadyCompleted = true;
      _currentExerciseIndex = 0;

      if (_currentProgress!.attempts.isNotEmpty) {
        _showingResult = true;
        _isCorrectAnswer = _currentProgress!.attempts[0].isCorrect;
      }
    } else {
      _currentExerciseIndex =
          _currentProgress!.totalAttempts < _exercises.length
          ? _currentProgress!.totalAttempts
          : 0;
    }
  }

  Future<void> _generateAndSaveNewExercises({
    required RoadmapSection section,
    required double currentTheta,
    required String userId,
    required String roadmapId,
  }) async {
    if (_theoryContent == null) {
      throw Exception('Debe generar la teoría primero');
    }

    _exercises = await _exerciseService.generateExercises(
      subtopic: section.subtopic,
      description: section.description,
      currentTheta: currentTheta,
      objectives: section.objectives,
      theoryContent: _theoryContent!,
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
      theoryReviewed: true,
    );

    _currentExerciseIndex = 0;

    final saved = await _userService.saveSectionExercises(
      uid: userId,
      roadmapId: roadmapId,
      sectionId: section.id,
      exercises: _exercises,
    );

    if (!saved) {}
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
}

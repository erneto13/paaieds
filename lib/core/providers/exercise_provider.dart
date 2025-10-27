import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/exercise_models.dart';
import '../services/exercise_generation_service.dart';

/// Estados posibles de la sesión de ejercicios
enum ExerciseSessionState {
  idle,
  loading,
  exercising,
  reviewing,
  completed,
  error,
}

/// Provider para manejar el estado de los ejercicios dinámicos
class ExerciseProvider extends ChangeNotifier {
  final ExerciseGenerationService _exerciseService;
  
  ExerciseProvider(this._exerciseService);

  // Estado actual
  ExerciseSessionState _state = ExerciseSessionState.idle;
  ExerciseSessionState get state => _state;

  // Ejercicios actuales
  ExerciseSet? _currentExerciseSet;
  ExerciseSet? get currentExerciseSet => _currentExerciseSet;

  // Ejercicio actual
  int _currentExerciseIndex = 0;
  int get currentExerciseIndex => _currentExerciseIndex;
  
  Exercise? get currentExercise {
    if (_currentExerciseSet == null || 
        _currentExerciseIndex >= _currentExerciseSet!.ejercicios.length) {
      return null;
    }
    return _currentExerciseSet!.ejercicios[_currentExerciseIndex];
  }

  // Respuestas del usuario
  final List<ExerciseAnswer> _userAnswers = [];
  List<ExerciseAnswer> get userAnswers => List.unmodifiable(_userAnswers);

  // Datos de la sesión
  DateTime? _sessionStartTime;
  DateTime? _exerciseStartTime;
  String _currentSubtema = '';
  double _currentTheta = 0.0;
  
  String get currentSubtema => _currentSubtema;
  double get currentTheta => _currentTheta;
  bool get isLastExercise => 
      _currentExerciseSet != null && 
      _currentExerciseIndex >= _currentExerciseSet!.ejercicios.length - 1;
  
  int get totalExercises => _currentExerciseSet?.ejercicios.length ?? 0;
  int get completedExercises => _userAnswers.length;
  double get progress => totalExercises > 0 ? completedExercises / totalExercises : 0.0;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Inicia una nueva sesión de ejercicios
  Future<void> startExerciseSession({
    required String subtema,
    required double theta,
    int exerciseCount = 5,
  }) async {
    try {
      _setState(ExerciseSessionState.loading);
      _clearSession();
      
      _currentSubtema = subtema;
      _currentTheta = theta;
      _sessionStartTime = DateTime.now();
      
      _currentExerciseSet = await _exerciseService.generateExercises(
        subtema: subtema,
        theta: theta,
        exerciseCount: exerciseCount,
      );
      
      if (_currentExerciseSet!.ejercicios.isEmpty) {
        throw Exception('No se generaron ejercicios para el subtema');
      }
      
      _currentExerciseIndex = 0;
      _exerciseStartTime = DateTime.now();
      _setState(ExerciseSessionState.exercising);
      
    } catch (e) {
      _setError('Error al generar ejercicios: $e');
    }
  }

  /// Inicia sesión de ejercicios de refuerzo
  Future<void> startRemedialSession({
    required String subtema,
    required double theta,
    required List<String> failedConcepts,
  }) async {
    try {
      _setState(ExerciseSessionState.loading);
      _clearSession();
      
      _currentSubtema = subtema;
      _currentTheta = theta;
      _sessionStartTime = DateTime.now();
      
      _currentExerciseSet = await _exerciseService.generateRemedialExercises(
        subtema: subtema,
        theta: theta,
        failedConcepts: failedConcepts,
      );
      
      _currentExerciseIndex = 0;
      _exerciseStartTime = DateTime.now();
      _setState(ExerciseSessionState.exercising);
      
    } catch (e) {
      _setError('Error al generar ejercicios de refuerzo: $e');
    }
  }

  /// Inicia sesión de ejercicios avanzados
  Future<void> startAdvancedSession({
    required String subtema,
    required double theta,
  }) async {
    try {
      _setState(ExerciseSessionState.loading);
      _clearSession();
      
      _currentSubtema = subtema;
      _currentTheta = theta;
      _sessionStartTime = DateTime.now();
      
      _currentExerciseSet = await _exerciseService.generateAdvancedExercises(
        subtema: subtema,
        theta: theta,
      );
      
      _currentExerciseIndex = 0;
      _exerciseStartTime = DateTime.now();
      _setState(ExerciseSessionState.exercising);
      
    } catch (e) {
      _setError('Error al generar ejercicios avanzados: $e');
    }
  }

  /// Envía la respuesta del usuario para el ejercicio actual
  void submitAnswer(dynamic userAnswer) {
    if (currentExercise == null || _exerciseStartTime == null) {
      return;
    }

    final exercise = currentExercise!;
    final isCorrect = exercise.isCorrect(userAnswer);
    final timeSpent = DateTime.now().difference(_exerciseStartTime!);
    
    final answer = ExerciseAnswer(
      exerciseId: exercise.id,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      timeSpent: timeSpent,
    );
    
    _userAnswers.add(answer);
    
    // Mostrar retroalimentación
    _setState(ExerciseSessionState.reviewing);
    notifyListeners();
  }

  /// Avanza al siguiente ejercicio o completa la sesión
  void nextExercise() {
    if (_state != ExerciseSessionState.reviewing) return;
    
    if (isLastExercise) {
      _completeSession();
    } else {
      _currentExerciseIndex++;
      _exerciseStartTime = DateTime.now();
      _setState(ExerciseSessionState.exercising);
    }
  }

  /// Completa la sesión actual
  void _completeSession() {
    if (_sessionStartTime == null) return;
    
    _setState(ExerciseSessionState.completed);
  }

  /// Obtiene el resultado de la sesión actual
  ExerciseSessionResult? getSessionResult() {
    if (_sessionStartTime == null || _state != ExerciseSessionState.completed) {
      return null;
    }
    
    return ExerciseSessionResult(
      subtema: _currentSubtema,
      answers: _userAnswers,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      oldTheta: _currentTheta,
      newTheta: _calculateNewTheta(), // Esto debería ser calculado por el servicio IRT
    );
  }

  /// Calcula el nuevo theta basado en las respuestas (simplificado)
  double _calculateNewTheta() {
    if (_userAnswers.isEmpty) return _currentTheta;
    
    final correctCount = _userAnswers.where((a) => a.isCorrect).length;
    final accuracy = correctCount / _userAnswers.length;
    
    // Cálculo simplificado - en la implementación real usaría IRT
    double adjustment = 0.0;
    
    if (accuracy >= 0.8) {
      adjustment = 0.3; // Mejora significativa
    } else if (accuracy >= 0.6) {
      adjustment = 0.1; // Mejora leve
    } else if (accuracy >= 0.4) {
      adjustment = -0.1; // Disminución leve
    } else {
      adjustment = -0.3; // Disminución significativa
    }
    
    return (_currentTheta + adjustment).clamp(-3.0, 3.0);
  }

  /// Obtiene conceptos en los que el usuario falló
  List<String> getFailedConcepts() {
    if (_currentExerciseSet == null) return [];
    
    final failedAnswers = _userAnswers.where((a) => !a.isCorrect);
    final failedExercises = failedAnswers
        .map((a) => _currentExerciseSet!.ejercicios
            .firstWhereOrNull((e) => e.id == a.exerciseId))
        .where((e) => e != null)
        .cast<Exercise>();
    
    // Extraer conceptos de los enunciados (simplificado)
    return failedExercises
        .map((e) => _extractConcepts(e.enunciado))
        .expand((concepts) => concepts)
        .toSet()
        .toList();
  }

  /// Extrae conceptos clave del enunciado (simplificado)
  List<String> _extractConcepts(String enunciado) {
    // En una implementación más sofisticada, usaría NLP
    final keywords = [
      'StatefulWidget', 'StatelessWidget', 'setState', 'build',
      'Navigator', 'Route', 'Context', 'Widget', 'State',
      'async', 'await', 'Future', 'Stream', 'null safety',
    ];
    
    return keywords
        .where((keyword) => enunciado.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  /// Reinicia el provider
  void reset() {
    _clearSession();
    _setState(ExerciseSessionState.idle);
  }

  /// Limpia la sesión actual
  void _clearSession() {
    _currentExerciseSet = null;
    _currentExerciseIndex = 0;
    _userAnswers.clear();
    _sessionStartTime = null;
    _exerciseStartTime = null;
    _currentSubtema = '';
    _currentTheta = 0.0;
    _errorMessage = null;
  }

  /// Establece el estado y notifica
  void _setState(ExerciseSessionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Establece un error
  void _setError(String message) {
    _errorMessage = message;
    _setState(ExerciseSessionState.error);
  }

  /// Limpia el error actual
  void clearError() {
    _errorMessage = null;
    if (_state == ExerciseSessionState.error) {
      _setState(ExerciseSessionState.idle);
    }
  }

  @override
  void dispose() {
    _exerciseService.dispose();
    super.dispose();
  }
}

/// Extensión para obtener información adicional del ejercicio actual
extension ExerciseProviderExtensions on ExerciseProvider {
  /// Obtiene el tipo del ejercicio actual
  ExerciseType? get currentExerciseType => currentExercise?.tipo;
  
  /// Verifica si hay ejercicios disponibles
  bool get hasExercises => 
      currentExerciseSet != null && currentExerciseSet!.ejercicios.isNotEmpty;
  
  /// Obtiene la respuesta del usuario para el ejercicio actual
  ExerciseAnswer? get currentAnswer {
    if (currentExercise == null) return null;
    return userAnswers.firstWhereOrNull(
      (answer) => answer.exerciseId == currentExercise!.id,
    );
  }
  
  /// Verifica si el ejercicio actual ya fue respondido
  bool get isCurrentExerciseAnswered => currentAnswer != null;
  
  /// Obtiene estadísticas de la sesión actual
  Map<String, dynamic> get sessionStats {
    final correctAnswers = userAnswers.where((a) => a.isCorrect).length;
    final totalTime = userAnswers.fold<Duration>(
      Duration.zero,
      (sum, answer) => sum + answer.timeSpent,
    );
    
    return {
      'correct': correctAnswers,
      'total': userAnswers.length,
      'accuracy': userAnswers.isNotEmpty ? correctAnswers / userAnswers.length : 0.0,
      'totalTime': totalTime,
      'averageTime': userAnswers.isNotEmpty 
          ? Duration(milliseconds: totalTime.inMilliseconds ~/ userAnswers.length)
          : Duration.zero,
    };
  }
}
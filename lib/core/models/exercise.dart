import 'dart:convert';

enum ExerciseType { multipleChoice, blockOrder, code, matching }

class Exercise {
  final String id;
  final ExerciseType type;
  final String statement;
  final Map<String, dynamic> data;
  final String correctAnswer;
  final String feedback;
  final double difficulty;

  Exercise({
    required this.id,
    required this.type,
    required this.statement,
    required this.data,
    required this.correctAnswer,
    required this.feedback,
    required this.difficulty,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    ExerciseType exerciseType;

    switch (json['type']?.toLowerCase()) {
      case 'multiple_choice':
        exerciseType = ExerciseType.multipleChoice;
        break;
      case 'block_order':
        exerciseType = ExerciseType.blockOrder;
        break;
      case 'code':
        exerciseType = ExerciseType.code;
        break;
      case 'matching':
        exerciseType = ExerciseType.matching;
        break;
      default:
        exerciseType = ExerciseType.multipleChoice;
    }

    return Exercise(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: exerciseType,
      statement: json['statement'] ?? '',
      data: Map<String, dynamic>.from(json),
      correctAnswer: _extractCorrectAnswer(json, exerciseType),
      feedback: json['feedback'] ?? '',
      difficulty: (json['difficulty'] ?? 0.5).toDouble(),
    );
  }

  static String _extractCorrectAnswer(
    Map<String, dynamic> json,
    ExerciseType type,
  ) {
    switch (type) {
      case ExerciseType.multipleChoice:
        return json['correctAnswer'] ?? '';

      case ExerciseType.blockOrder:
        final correctOrder = json['correctOrder'] as List<dynamic>?;
        return correctOrder?.join('|') ?? '';

      case ExerciseType.code:
        //para ejercicios tipo code, ahora la respuesta correcta es una de las opciones
        return json['correctAnswer'] ?? '';

      case ExerciseType.matching:
        //para matching, guardamos el mapa de relaciones correctas como json
        final correctMatches = json['correctMatches'];
        if (correctMatches != null) {
          return jsonEncode(correctMatches);
        }
        return '{}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'statement': statement,
      'correctAnswer': correctAnswer,
      'feedback': feedback,
      'difficulty': difficulty,
      ...data,
    };
  }

  String _typeToString(ExerciseType type) {
    switch (type) {
      case ExerciseType.multipleChoice:
        return 'multiple_choice';
      case ExerciseType.blockOrder:
        return 'block_order';
      case ExerciseType.code:
        return 'code';
      case ExerciseType.matching:
        return 'matching';
    }
  }
}

class ExerciseAttempt {
  final String exerciseId;
  final String userAnswer;
  final bool isCorrect;
  final DateTime timestamp;

  ExerciseAttempt({
    required this.exerciseId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SectionProgress {
  final String sectionId;
  final double currentTheta;
  final List<ExerciseAttempt> attempts;
  final int correctCount;
  final int totalAttempts;
  final bool isCompleted;

  SectionProgress({
    required this.sectionId,
    required this.currentTheta,
    required this.attempts,
    required this.correctCount,
    required this.totalAttempts,
    this.isCompleted = false,
  });

  double get accuracy => totalAttempts > 0 ? correctCount / totalAttempts : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'currentTheta': currentTheta,
      'attempts': attempts.map((a) => a.toJson()).toList(),
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
      'isCompleted': isCompleted,
    };
  }
}

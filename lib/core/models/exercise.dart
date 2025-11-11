import 'dart:convert';

enum ExerciseType { multipleChoice, blockOrder, code, matching }

class TheoryContent {
  final String introduction;
  final List<TheorySection> sections;
  final List<String> keyPoints;
  final List<String> examples;

  TheoryContent({
    required this.introduction,
    required this.sections,
    required this.keyPoints,
    required this.examples,
  });

  factory TheoryContent.fromJson(Map<String, dynamic> json) {
    return TheoryContent(
      introduction: json['introduction'] ?? '',
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((s) => TheorySection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      examples: List<String>.from(json['examples'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'introduction': introduction,
      'sections': sections.map((s) => s.toJson()).toList(),
      'keyPoints': keyPoints,
      'examples': examples,
    };
  }
}

class TheorySection {
  final String title;
  final String content;

  TheorySection({required this.title, required this.content});

  factory TheorySection.fromJson(Map<String, dynamic> json) {
    return TheorySection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}

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
        return json['correctAnswer'] ?? '';

      case ExerciseType.matching:
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
  final bool theoryReviewed;

  SectionProgress({
    required this.sectionId,
    required this.currentTheta,
    required this.attempts,
    required this.correctCount,
    required this.totalAttempts,
    this.isCompleted = false,
    this.theoryReviewed = false,
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
      'theoryReviewed': theoryReviewed,
    };
  }
}

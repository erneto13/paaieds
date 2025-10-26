import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionDetail {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String userAnswer;
  final bool isCorrect;

  QuestionDetail({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    };
  }

  factory QuestionDetail.fromMap(Map<String, dynamic> map) {
    return QuestionDetail(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      userAnswer: map['userAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}

class TestResult {
  final String id;
  final String topic;
  final String level;
  final double theta;
  final double percentage;
  final int correctAnswers;
  final int totalQuestions;
  final Timestamp completedAt;
  final List<QuestionDetail>? questions;

  TestResult({
    required this.id,
    required this.topic,
    required this.level,
    required this.theta,
    required this.percentage,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completedAt,
    this.questions,
  });

  factory TestResult.fromMap(Map<String, dynamic> map, String id) {
    List<QuestionDetail>? questionsList;

    if (map['questions'] != null) {
      questionsList = (map['questions'] as List)
          .map((q) => QuestionDetail.fromMap(q as Map<String, dynamic>))
          .toList();
    }

    return TestResult(
      id: id,
      topic: map['topic'] ?? '',
      level: map['level'] ?? '',
      theta: (map['theta'] ?? 0.0).toDouble(),
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      completedAt: map['completedAt'] ?? Timestamp.now(),
      questions: questionsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'level': level,
      'theta': theta,
      'percentage': percentage,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt,
      if (questions != null)
        'questions': questions!.map((q) => q.toMap()).toList(),
    };
  }

  List<QuestionDetail> getIncorrectAnswers() {
    return questions?.where((q) => !q.isCorrect).toList() ?? [];
  }

  List<QuestionDetail> getCorrectAnswers() {
    return questions?.where((q) => q.isCorrect).toList() ?? [];
  }
}

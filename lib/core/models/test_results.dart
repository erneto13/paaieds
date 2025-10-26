import 'package:cloud_firestore/cloud_firestore.dart';

class TestResult {
  final String id;
  final String topic;
  final String level;
  final double theta;
  final double percentage;
  final int correctAnswers;
  final int totalQuestions;
  final Timestamp completedAt;

  TestResult({
    required this.id,
    required this.topic,
    required this.level,
    required this.theta,
    required this.percentage,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory TestResult.fromMap(Map<String, dynamic> map, String id) {
    return TestResult(
      id: id,
      topic: map['topic'] ?? '',
      level: map['level'] ?? '',
      theta: (map['theta'] ?? 0.0).toDouble(),
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      completedAt: map['completedAt'] ?? Timestamp.now(),
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
    };
  }
}

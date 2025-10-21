class QuestionModel {
  final String question;
  final List<String> options;
  final String answer;

  QuestionModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
    );
  }
}

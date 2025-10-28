class RoadmapSection {
  final String id;
  final String bloomLevel;
  final String subtopic;
  final String description;
  final String baseDifficulty;
  final List<String> objectives;
  final bool completed;
  final double? finalTheta;
  final int order;

  RoadmapSection({
    required this.id,
    required this.bloomLevel,
    required this.subtopic,
    required this.description,
    required this.baseDifficulty,
    required this.objectives,
    this.completed = false,
    this.finalTheta,
    required this.order,
  });

  factory RoadmapSection.fromJson(Map<String, dynamic> json, int order) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final subtopic = json['subtopic'] ?? '';
    final uniqueId =
        json['id'] ?? '$timestamp-$order-${subtopic.hashCode.abs()}';

    return RoadmapSection(
      id: uniqueId,
      bloomLevel: json['bloomLevel'] ?? '',
      subtopic: subtopic,
      description: json['description'] ?? '',
      baseDifficulty: json['baseDifficulty'] ?? 'medium',
      objectives: List<String>.from(json['objectives'] ?? []),
      completed: json['completed'] ?? false,
      finalTheta: json['finalTheta']?.toDouble() ?? 0.0,
      order: order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bloomLevel': bloomLevel,
      'subtopic': subtopic,
      'description': description,
      'baseDifficulty': baseDifficulty,
      'objectives': objectives,
      'completed': completed,
      'finalTheta': finalTheta,
      'order': order,
    };
  }

  RoadmapSection copyWith({
    String? id,
    String? bloomLevel,
    String? subtopic,
    String? description,
    String? baseDifficulty,
    List<String>? objectives,
    bool? completed,
    double? finalTheta,
    int? order,
  }) {
    return RoadmapSection(
      id: id ?? this.id,
      bloomLevel: bloomLevel ?? this.bloomLevel,
      subtopic: subtopic ?? this.subtopic,
      description: description ?? this.description,
      baseDifficulty: baseDifficulty ?? this.baseDifficulty,
      objectives: objectives ?? this.objectives,
      completed: completed ?? this.completed,
      finalTheta: finalTheta ?? this.finalTheta,
      order: order ?? this.order,
    );
  }
}

class Roadmap {
  final String id;
  final String topic;
  final String level;
  final double initialTheta;
  final List<RoadmapSection> sections;
  final DateTime createdAt;

  Roadmap({
    required this.id,
    required this.topic,
    required this.level,
    required this.initialTheta,
    required this.sections,
    required this.createdAt,
  });

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    final sectionsData = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsData.asMap().entries.map((entry) {
      return RoadmapSection.fromJson(
        entry.value as Map<String, dynamic>,
        entry.key,
      );
    }).toList();

    return Roadmap(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      topic: json['topic'] ?? '',
      level: json['level'] ?? '',
      initialTheta: (json['initialTheta'] ?? 0.0).toDouble(),
      sections: sections,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'level': level,
      'initialTheta': initialTheta,
      'sections': sections.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get totalSections => sections.length;
  int get completedSections => sections.where((s) => s.completed).length;
  double get progressPercentage =>
      totalSections > 0 ? (completedSections / totalSections) * 100 : 0;
}

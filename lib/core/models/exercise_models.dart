import 'package:equatable/equatable.dart';

/// Tipos de ejercicios disponibles
enum ExerciseType {
  seleccionMultiple('seleccion_multiple'),
  bloques('bloques'),
  codigo('codigo');

  const ExerciseType(this.value);
  final String value;

  static ExerciseType fromString(String value) {
    return ExerciseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ExerciseType.seleccionMultiple,
    );
  }
}

/// Modelo base para todos los ejercicios
abstract class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.tipo,
    required this.enunciado,
    required this.retroalimentacion,
    this.dificultad = 1.0,
  });

  final String id;
  final ExerciseType tipo;
  final String enunciado;
  final String retroalimentacion;
  final double dificultad;

  /// Verifica si la respuesta del usuario es correcta
  bool isCorrect(dynamic userAnswer);

  @override
  List<Object?> get props => [id, tipo, enunciado, retroalimentacion, dificultad];
}

/// Ejercicio de selección múltiple
class MultipleChoiceExercise extends Exercise {
  const MultipleChoiceExercise({
    required super.id,
    required super.enunciado,
    required super.retroalimentacion,
    required this.opciones,
    required this.respuestaCorrecta,
    super.dificultad,
  }) : super(tipo: ExerciseType.seleccionMultiple);

  final List<String> opciones;
  final String respuestaCorrecta;

  @override
  bool isCorrect(dynamic userAnswer) {
    return userAnswer == respuestaCorrecta;
  }

  @override
  List<Object?> get props => [...super.props, opciones, respuestaCorrecta];

  factory MultipleChoiceExercise.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceExercise(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      enunciado: json['enunciado'] ?? '',
      opciones: List<String>.from(json['opciones'] ?? []),
      respuestaCorrecta: json['respuestaCorrecta'] ?? '',
      retroalimentacion: json['retroalimentacion'] ?? '',
      dificultad: (json['dificultad'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.value,
      'enunciado': enunciado,
      'opciones': opciones,
      'respuestaCorrecta': respuestaCorrecta,
      'retroalimentacion': retroalimentacion,
      'dificultad': dificultad,
    };
  }
}

/// Ejercicio de ordenar bloques
class BlockOrderExercise extends Exercise {
  const BlockOrderExercise({
    required super.id,
    required super.enunciado,
    required super.retroalimentacion,
    required this.bloques,
    required this.ordenCorrecto,
    super.dificultad,
  }) : super(tipo: ExerciseType.bloques);

  final List<String> bloques;
  final List<String> ordenCorrecto;

  @override
  bool isCorrect(dynamic userAnswer) {
    if (userAnswer is! List<String>) return false;
    if (userAnswer.length != ordenCorrecto.length) return false;
    
    for (int i = 0; i < ordenCorrecto.length; i++) {
      if (userAnswer[i] != ordenCorrecto[i]) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [...super.props, bloques, ordenCorrecto];

  factory BlockOrderExercise.fromJson(Map<String, dynamic> json) {
    return BlockOrderExercise(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      enunciado: json['enunciado'] ?? '',
      bloques: List<String>.from(json['bloques'] ?? []),
      ordenCorrecto: List<String>.from(json['ordenCorrecto'] ?? []),
      retroalimentacion: json['retroalimentacion'] ?? '',
      dificultad: (json['dificultad'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.value,
      'enunciado': enunciado,
      'bloques': bloques,
      'ordenCorrecto': ordenCorrecto,
      'retroalimentacion': retroalimentacion,
      'dificultad': dificultad,
    };
  }
}

/// Ejercicio de completar código
class CodeExercise extends Exercise {
  const CodeExercise({
    required super.id,
    required super.enunciado,
    required super.retroalimentacion,
    required this.codigoBase,
    required this.respuestaCorrecta,
    required this.lenguaje,
    this.espaciosVacios = const [],
    super.dificultad,
  }) : super(tipo: ExerciseType.codigo);

  final String codigoBase;
  final String respuestaCorrecta;
  final String lenguaje;
  final List<String> espaciosVacios; // Para ejercicios de llenar espacios

  @override
  bool isCorrect(dynamic userAnswer) {
    if (userAnswer is String) {
      // Normalizar espacios y comparar
      String normalizedUser = userAnswer.replaceAll(RegExp(r'\s+'), ' ').trim();
      String normalizedCorrect = respuestaCorrecta.replaceAll(RegExp(r'\s+'), ' ').trim();
      return normalizedUser.toLowerCase() == normalizedCorrect.toLowerCase();
    }
    return false;
  }

  @override
  List<Object?> get props => [
    ...super.props, 
    codigoBase, 
    respuestaCorrecta, 
    lenguaje, 
    espaciosVacios
  ];

  factory CodeExercise.fromJson(Map<String, dynamic> json) {
    return CodeExercise(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      enunciado: json['enunciado'] ?? '',
      codigoBase: json['codigoBase'] ?? '',
      respuestaCorrecta: json['respuestaCorrecta'] ?? '',
      lenguaje: json['lenguaje'] ?? 'dart',
      espaciosVacios: List<String>.from(json['espaciosVacios'] ?? []),
      retroalimentacion: json['retroalimentacion'] ?? '',
      dificultad: (json['dificultad'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.value,
      'enunciado': enunciado,
      'codigoBase': codigoBase,
      'respuestaCorrecta': respuestaCorrecta,
      'lenguaje': lenguaje,
      'espaciosVacios': espaciosVacios,
      'retroalimentacion': retroalimentacion,
      'dificultad': dificultad,
    };
  }
}

/// Conjunto de ejercicios para un subtema
class ExerciseSet extends Equatable {
  const ExerciseSet({
    required this.subtema,
    required this.ejercicios,
    this.metadata = const {},
  });

  final String subtema;
  final List<Exercise> ejercicios;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [subtema, ejercicios, metadata];

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    List<Exercise> exercises = [];
    
    if (json['ejercicios'] is List) {
      for (var exerciseJson in json['ejercicios']) {
        if (exerciseJson is Map<String, dynamic>) {
          final tipo = ExerciseType.fromString(exerciseJson['tipo'] ?? '');
          
          switch (tipo) {
            case ExerciseType.seleccionMultiple:
              exercises.add(MultipleChoiceExercise.fromJson(exerciseJson));
              break;
            case ExerciseType.bloques:
              exercises.add(BlockOrderExercise.fromJson(exerciseJson));
              break;
            case ExerciseType.codigo:
              exercises.add(CodeExercise.fromJson(exerciseJson));
              break;
          }
        }
      }
    }

    return ExerciseSet(
      subtema: json['subtema'] ?? '',
      ejercicios: exercises,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtema': subtema,
      'ejercicios': ejercicios.map((e) {
        if (e is MultipleChoiceExercise) return e.toJson();
        if (e is BlockOrderExercise) return e.toJson();
        if (e is CodeExercise) return e.toJson();
        return {};
      }).toList(),
      'metadata': metadata,
    };
  }
}

/// Respuesta del usuario a un ejercicio
class ExerciseAnswer extends Equatable {
  const ExerciseAnswer({
    required this.exerciseId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timeSpent,
    this.attempts = 1,
  });

  final String exerciseId;
  final dynamic userAnswer;
  final bool isCorrect;
  final Duration timeSpent;
  final int attempts;

  @override
  List<Object?> get props => [exerciseId, userAnswer, isCorrect, timeSpent, attempts];

  factory ExerciseAnswer.fromJson(Map<String, dynamic> json) {
    return ExerciseAnswer(
      exerciseId: json['exerciseId'] ?? '',
      userAnswer: json['userAnswer'],
      isCorrect: json['isCorrect'] ?? false,
      timeSpent: Duration(milliseconds: json['timeSpent'] ?? 0),
      attempts: json['attempts'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent.inMilliseconds,
      'attempts': attempts,
    };
  }
}

/// Resultado de una sesión de ejercicios
class ExerciseSessionResult extends Equatable {
  const ExerciseSessionResult({
    required this.subtema,
    required this.answers,
    required this.startTime,
    required this.endTime,
    required this.oldTheta,
    required this.newTheta,
  });

  final String subtema;
  final List<ExerciseAnswer> answers;
  final DateTime startTime;
  final DateTime endTime;
  final double oldTheta;
  final double newTheta;

  Duration get totalTime => endTime.difference(startTime);
  int get correctAnswers => answers.where((a) => a.isCorrect).length;
  int get totalQuestions => answers.length;
  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
  bool get improved => newTheta > oldTheta;

  @override
  List<Object?> get props => [
    subtema, answers, startTime, endTime, oldTheta, newTheta
  ];

  factory ExerciseSessionResult.fromJson(Map<String, dynamic> json) {
    return ExerciseSessionResult(
      subtema: json['subtema'] ?? '',
      answers: (json['answers'] as List? ?? [])
          .map((a) => ExerciseAnswer.fromJson(a))
          .toList(),
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] ?? 0),
      oldTheta: (json['oldTheta'] ?? 0.0).toDouble(),
      newTheta: (json['newTheta'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtema': subtema,
      'answers': answers.map((a) => a.toJson()).toList(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'oldTheta': oldTheta,
      'newTheta': newTheta,
    };
  }
}
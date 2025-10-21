import 'dart:math';

class IRTService {
  /// calcula la habilidad estimada (theta) basada en respuestas
  ///
  /// implementación simplificada del modelo logístico de 2 parámetros
  /// θ (theta) representa el nivel de habilidad del usuario
  ///
  /// retorna un objeto con:
  /// - theta: nivel de habilidad estimado (-3 a +3)
  /// - level: clasificación ("Básico", "Intermedio", "Avanzado")
  /// - percentage: porcentaje de dominio (0-100)
  static Map<String, dynamic> evaluateAbility({
    required List<Map<String, dynamic>> responses,
    int maxIterations = 5,
  }) {
    double theta = 0.0; //inicializacion de theta

    //parámetros de las preguntas (en producción vendrían calibrados)
    final questionParams = _generateQuestionParameters(responses.length);

    //iteración para estimar theta usando Maximum Likelihood
    for (int iter = 0; iter < maxIterations; iter++) {
      double numerator = 0.0;
      double denominator = 0.0;

      for (int i = 0; i < responses.length; i++) {
        final isCorrect = responses[i]['isCorrect'] as bool;
        final difficulty = questionParams[i]['difficulty'];
        final discrimination = questionParams[i]['discrimination'];

        //calcular probabilidad de respuesta correcta
        final prob = _calculateProbability(theta, difficulty!, discrimination!);

        //actualizar numerator y denominator para Newton-Raphson
        final y = isCorrect ? 1.0 : 0.0;
        numerator += discrimination * (y - prob);
        denominator += discrimination * discrimination * prob * (1 - prob);
      }

      //actualiza theta
      if (denominator != 0) {
        theta += numerator / denominator;
      }

      //limitar theta a rango razonable
      theta = theta.clamp(-3.0, 3.0);
    }

    return {
      'theta': theta,
      'level': _classifyLevel(theta),
      'percentage': _thetaToPercentage(theta),
      'correctAnswers': responses.where((r) => r['isCorrect'] == true).length,
      'totalQuestions': responses.length,
    };
  }

  ///calcula la probabilidad de respuesta correcta según IRT
  static double _calculateProbability(
    double theta,
    double difficulty,
    double discrimination,
  ) {
    final exponent = -discrimination * (theta - difficulty);
    return 1.0 / (1.0 + exp(exponent));
  }

  ///genera parámetros de dificultad y discriminación para las preguntas
  static List<Map<String, double>> _generateQuestionParameters(int count) {
    final params = <Map<String, double>>[];

    for (int i = 0; i < count; i++) {
      //distribución de dificultades de -2 a +2
      final difficulty = -2.0 + (4.0 * i / (count - 1));

      //discriminación típica entre 0.5 y 2.0
      final discrimination = 1.0 + (0.5 * sin(i * 0.5));

      params.add({'difficulty': difficulty, 'discrimination': discrimination});
    }

    return params;
  }

  //clasifica el nivel de habilidad basado en theta
  static String _classifyLevel(double theta) {
    if (theta < -0.5) {
      return 'Básico';
    } else if (theta < 0.5) {
      return 'Intermedio';
    } else {
      return 'Avanzado';
    }
  }

  //convierte theta a porcentaje (0-100)
  static double _thetaToPercentage(double theta) {
    //normalizar theta (-3 a +3) a porcentaje (0 a 100)
    return ((theta + 3.0) / 6.0 * 100.0).clamp(0.0, 100.0);
  }

  ///calcula el puntaje simple (para comparación)
  static Map<String, dynamic> calculateSimpleScore({
    required List<Map<String, dynamic>> responses,
  }) {
    final correct = responses.where((r) => r['isCorrect'] == true).length;
    final total = responses.length;
    final percentage = (correct / total * 100).roundToDouble();

    String level;
    if (percentage < 50) {
      level = 'Básico';
    } else if (percentage < 75) {
      level = 'Intermedio';
    } else {
      level = 'Avanzado';
    }

    return {
      'correctAnswers': correct,
      'totalQuestions': total,
      'percentage': percentage,
      'level': level,
    };
  }
}

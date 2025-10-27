import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/exercise_models.dart';

/// Servicio para generar ejercicios dinámicos basados en theta y subtema
class ExerciseGenerationService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';
  
  final String _apiKey;
  final http.Client _httpClient;
  final Random _random = Random();

  ExerciseGenerationService({
    required String apiKey,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client();

  /// Genera ejercicios para un subtema específico basado en el nivel theta
  Future<ExerciseSet> generateExercises({
    required String subtema,
    required double theta,
    int exerciseCount = 5,
    bool isRemedial = false,
    List<String> failedConcepts = const [],
  }) async {
    try {
      final prompt = _buildPrompt(
        subtema: subtema,
        theta: theta,
        exerciseCount: exerciseCount,
        isRemedial: isRemedial,
        failedConcepts: failedConcepts,
      );

      final response = await _callOpenAI(prompt);
      return _parseExerciseResponse(response, subtema);
    } catch (e) {
      // Si falla la generación con IA, usar ejercicios predeterminados
      return _generateFallbackExercises(subtema, theta, exerciseCount);
    }
  }

  /// Genera ejercicios de refuerzo para conceptos específicos donde el estudiante falló
  Future<ExerciseSet> generateRemedialExercises({
    required String subtema,
    required double theta,
    required List<String> failedConcepts,
    int exerciseCount = 3,
  }) async {
    return generateExercises(
      subtema: subtema,
      theta: theta,
      exerciseCount: exerciseCount,
      isRemedial: true,
      failedConcepts: failedConcepts,
    );
  }

  /// Genera ejercicios de nivel superior para el siguiente subtema
  Future<ExerciseSet> generateAdvancedExercises({
    required String subtema,
    required double theta,
    int exerciseCount = 5,
  }) async {
    return generateExercises(
      subtema: subtema,
      theta: theta + 0.2, // Aumentar ligeramente la dificultad
      exerciseCount: exerciseCount,
    );
  }

  /// Construye el prompt para la generación de ejercicios
  String _buildPrompt({
    required String subtema,
    required double theta,
    required int exerciseCount,
    required bool isRemedial,
    required List<String> failedConcepts,
  }) {
    final difficultyLevel = _getThetaDescription(theta);
    final remedialText = isRemedial && failedConcepts.isNotEmpty
        ? 'Enfócate especialmente en estos conceptos donde el estudiante falló: ${failedConcepts.join(", ")}. '
        : '';

    return '''
Genera un conjunto de $exerciseCount ejercicios para el subtema "$subtema" considerando un nivel de conocimiento con θ=$theta ($difficultyLevel).

${remedialText}Incluye tipos variados ('seleccion_multiple', 'bloques', 'codigo') con dificultad ajustada al nivel del estudiante.

Para ejercicios de selección múltiple:
- Incluye 4 opciones plausibles
- Solo una opción correcta
- Retroalimentación explicativa

Para ejercicios de bloques:
- 4-6 bloques para ordenar
- Secuencia lógica clara
- Conceptos fundamentales del tema

Para ejercicios de código:
- Código en Dart/Flutter relevante al subtema
- Espacios en blanco o código completo según dificultad
- Explicación de la solución

Responde ÚNICAMENTE con un JSON válido en este formato exacto:
{
  "subtema": "$subtema",
  "ejercicios": [
    {
      "tipo": "seleccion_multiple",
      "enunciado": "Pregunta clara y específica",
      "opciones": ["opción1", "opción2", "opción3", "opción4"],
      "respuestaCorrecta": "opción correcta",
      "retroalimentacion": "Explicación detallada",
      "dificultad": ${theta.toStringAsFixed(2)}
    },
    {
      "tipo": "bloques",
      "enunciado": "Instrucción para ordenar",
      "bloques": ["bloque1", "bloque2", "bloque3", "bloque4"],
      "ordenCorrecto": ["bloque1", "bloque2", "bloque3", "bloque4"],
      "retroalimentacion": "Explicación del orden correcto",
      "dificultad": ${theta.toStringAsFixed(2)}
    },
    {
      "tipo": "codigo",
      "enunciado": "Descripción del ejercicio de código",
      "codigoBase": "código con espacios _____ o código completo",
      "respuestaCorrecta": "solución correcta",
      "lenguaje": "dart",
      "espaciosVacios": ["respuesta1", "respuesta2"],
      "retroalimentacion": "Explicación de la solución",
      "dificultad": ${theta.toStringAsFixed(2)}
    }
  ]
}
''';
  }

  /// Llama a la API de OpenAI para generar ejercicios
  Future<String> _callOpenAI(String prompt) async {
    final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'Eres un experto en educación y Flutter/Dart que genera ejercicios educativos dinámicos. Responde únicamente con JSON válido.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.3,
        'max_tokens': 2000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Error al generar ejercicios: ${response.statusCode}');
    }
  }

  /// Parsea la respuesta de la IA y crea un ExerciseSet
  ExerciseSet _parseExerciseResponse(String response, String subtema) {
    try {
      // Limpiar la respuesta eliminando bloques de código si existen
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      final jsonData = jsonDecode(cleanResponse);
      return ExerciseSet.fromJson(jsonData);
    } catch (e) {
      throw Exception('Error al parsear respuesta de ejercicios: $e');
    }
  }

  /// Genera ejercicios predeterminados como respaldo
  ExerciseSet _generateFallbackExercises(String subtema, double theta, int count) {
    final exercises = <Exercise>[];
    
    // Generar ejercicios básicos basados en el subtema
    for (int i = 0; i < count; i++) {
      switch (i % 3) {
        case 0:
          exercises.add(_createFallbackMultipleChoice(subtema, theta));
          break;
        case 1:
          exercises.add(_createFallbackBlockOrder(subtema, theta));
          break;
        case 2:
          exercises.add(_createFallbackCode(subtema, theta));
          break;
      }
    }

    return ExerciseSet(
      subtema: subtema,
      ejercicios: exercises,
      metadata: {'generated': 'fallback', 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  Exercise _createFallbackMultipleChoice(String subtema, double theta) {
    return MultipleChoiceExercise(
      id: 'fallback_mc_${_random.nextInt(10000)}',
      enunciado: '¿Cuál es un concepto fundamental de $subtema?',
      opciones: [
        'Opción A relacionada con $subtema',
        'Opción B relacionada con $subtema',
        'Opción C relacionada con $subtema',
        'Opción D relacionada con $subtema',
      ],
      respuestaCorrecta: 'Opción A relacionada con $subtema',
      retroalimentacion: 'Esta es la respuesta correcta para $subtema.',
      dificultad: theta,
    );
  }

  Exercise _createFallbackBlockOrder(String subtema, double theta) {
    return BlockOrderExercise(
      id: 'fallback_bo_${_random.nextInt(10000)}',
      enunciado: 'Ordena los siguientes pasos relacionados con $subtema:',
      bloques: [
        'Paso 1 de $subtema',
        'Paso 2 de $subtema',
        'Paso 3 de $subtema',
        'Paso 4 de $subtema',
      ],
      ordenCorrecto: [
        'Paso 1 de $subtema',
        'Paso 2 de $subtema',
        'Paso 3 de $subtema',
        'Paso 4 de $subtema',
      ],
      retroalimentacion: 'Este es el orden correcto para $subtema.',
      dificultad: theta,
    );
  }

  Exercise _createFallbackCode(String subtema, double theta) {
    return CodeExercise(
      id: 'fallback_code_${_random.nextInt(10000)}',
      enunciado: 'Completa el siguiente código relacionado con $subtema:',
      codigoBase: '// Código relacionado con $subtema\nvoid ejemplo() {\n  // Completa aquí\n  _____\n}',
      respuestaCorrecta: 'print("Ejemplo de $subtema");',
      lenguaje: 'dart',
      espaciosVacios: ['print("Ejemplo de $subtema");'],
      retroalimentacion: 'Esta es la implementación correcta para $subtema.',
      dificultad: theta,
    );
  }

  /// Convierte el valor theta en una descripción legible
  String _getThetaDescription(double theta) {
    if (theta < -1.0) return 'nivel principiante';
    if (theta < 0.0) return 'nivel básico';
    if (theta < 1.0) return 'nivel intermedio';
    if (theta < 2.0) return 'nivel avanzado';
    return 'nivel experto';
  }

  /// Libera recursos
  void dispose() {
    _httpClient.close();
  }
}

/// Configuración del servicio de generación de ejercicios
class ExerciseGenerationConfig {
  static const int defaultExerciseCount = 5;
  static const int remedialExerciseCount = 3;
  static const double difficultyIncrement = 0.2;
  
  static const Map<String, List<String>> subjectTemplates = {
    'flutter': [
      'Widget básicos',
      'StatefulWidget vs StatelessWidget',
      'Gestión de estado',
      'Navegación',
      'Layouts',
    ],
    'dart': [
      'Sintaxis básica',
      'Programación orientada a objetos',
      'Collections',
      'Async/Await',
      'Null Safety',
    ],
  };

  static const Map<ExerciseType, double> typeWeights = {
    ExerciseType.seleccionMultiple: 0.4,
    ExerciseType.bloques: 0.3,
    ExerciseType.codigo: 0.3,
  };
}
import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/util/json_parser.dart';

class ExerciseService {
  final GeminiService _geminiService = GeminiService();

  //detectar si el tema es relacionado a programacion
  bool _isProgrammingTopic(String subtopic, String description) {
    final programmingKeywords = [
      'código',
      'code',
      'programación',
      'programming',
      'función',
      'function',
      'variable',
      'método',
      'method',
      'clase',
      'class',
      'algoritmo',
      'algorithm',
      'sintaxis',
      'syntax',
      'javascript',
      'python',
      'java',
      'dart',
      'flutter',
      'react',
      'angular',
      'vue',
      'node',
      'api',
      'framework',
      'library',
      'debugging',
      'testing',
      'desarrollo',
      'development',
    ];

    final combinedText =
        '${subtopic.toLowerCase()} ${description.toLowerCase()}';

    return programmingKeywords.any((keyword) => combinedText.contains(keyword));
  }

  Future<List<Exercise>> generateExercises({
    required String subtopic,
    required String description,
    required double currentTheta,
    required List<String> objectives,
    int count = 5,
    bool isReinforcement = false,
  }) async {
    final isProgramming = _isProgrammingTopic(subtopic, description);

    final prompt = _buildExercisePrompt(
      subtopic: subtopic,
      description: description,
      currentTheta: currentTheta,
      objectives: objectives,
      count: count,
      isReinforcement: isReinforcement,
      isProgramming: isProgramming,
    );

    try {
      final result = await _geminiService.generateText(prompt);
      final jsonData = JsonParserUtil.parseJsonObject(result);

      final ejerciciosData = jsonData['exercises'] as List<dynamic>? ?? [];

      return ejerciciosData
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al generar ejercicios: $e');
    }
  }

  Future<List<Exercise>> generateReinforcementExercises({
    required String subtopic,
    required List<String> failedConcepts,
    required double currentTheta,
  }) async {
    return generateExercises(
      subtopic: subtopic,
      description: 'Refuerzo en: ${failedConcepts.join(", ")}',
      currentTheta: currentTheta,
      objectives: failedConcepts,
      count: 3,
      isReinforcement: true,
    );
  }

  String _buildExercisePrompt({
    required String subtopic,
    required String description,
    required double currentTheta,
    required List<String> objectives,
    required int count,
    required bool isReinforcement,
    required bool isProgramming,
  }) {
    final difficultyGuidance = _getDifficultyGuidance(currentTheta);
    final reinforcementNote = isReinforcement
        ? '\n**IMPORTANTE**: Estos son ejercicios de REFUERZO. Enfócate en los conceptos específicos donde el estudiante tuvo dificultades.'
        : '';

    //definir tipos de ejercicios segun el tema
    final exerciseTypes = isProgramming
        ? _getProgrammingExerciseTypes()
        : _getGeneralExerciseTypes();

    return '''
Genera $count ejercicios dinámicos para el subtema "$subtopic".
Descripción: $description
Nivel de conocimiento del estudiante (θ): $currentTheta

$difficultyGuidance$reinforcementNote

Objetivos de aprendizaje:
${objectives.map((o) => '- $o').join('\n')}

$exerciseTypes

**Requisitos**:
- Varía los tipos de ejercicios
- Ajusta la dificultad según el θ del estudiante
- Incluye retroalimentación educativa
- Asegúrate de que los ejercicios sean claros y verificables
- Devuelve SOLO el JSON, sin texto adicional

Genera los ejercicios ahora. No agregues texto adicional fuera del JSON. La respuesta debe ser únicamente el JSON.
''';
  }

  String _getProgrammingExerciseTypes() {
    return '''
**Tipos de ejercicios a incluir**:
1. **multiple_choice**: Preguntas con 4 opciones, una correcta.
2. **block_order**: Ordenar líneas de código o pasos de un algoritmo en el orden correcto.
3. **code**: Analizar un fragmento de código y seleccionar cuál será su salida/resultado.

**Estructura JSON esperada**:
{
  "subtopic": "nombre del tema",
  "exercises": [
    {
      "type": "multiple_choice",
      "statement": "Pregunta clara y específica",
      "options": ["Opción A", "Opción B", "Opción C", "Opción D"],
      "correctAnswer": "Opción correcta",
      "feedback": "Explicación breve de por qué es correcta",
      "difficulty": 0.6
    },
    {
      "type": "block_order",
      "statement": "Instrucción para ordenar líneas de código",
      "blocks": ["Línea 1", "Línea 2", "Línea 3", "Línea 4"],
      "correctOrder": ["Línea correcta 1", "Línea correcta 2", ...],
      "feedback": "Explicación del orden correcto",
      "difficulty": 0.7
    },
    {
      "type": "code",
      "statement": "¿Cuál será la salida de este código?",
      "codeSnippet": "código completo aquí",
      "outputOptions": ["Salida A", "Salida B", "Salida C", "Salida D"],
      "correctAnswer": "Salida correcta",
      "hints": ["Pista 1", "Pista 2"],
      "feedback": "Explicación de la salida",
      "difficulty": 0.8
    }
  ]
}
''';
  }

  String _getGeneralExerciseTypes() {
    return '''
**Tipos de ejercicios a incluir**:
1. **multiple_choice**: Preguntas con 4 opciones, una correcta.
2. **block_order**: Ordenar conceptos, pasos o elementos en el orden correcto.
3. **matching**: Relacionar elementos de una columna con elementos de otra columna.

**Estructura JSON esperada**:
{
  "subtopic": "nombre del tema",
  "exercises": [
    {
      "type": "multiple_choice",
      "statement": "Pregunta clara y específica sobre el concepto",
      "options": ["Opción A", "Opción B", "Opción C", "Opción D"],
      "correctAnswer": "Opción correcta",
      "feedback": "Explicación breve de por qué es correcta",
      "difficulty": 0.6
    },
    {
      "type": "block_order",
      "statement": "Instrucción para ordenar los elementos",
      "blocks": ["Paso 1", "Paso 2", "Paso 3", "Paso 4"],
      "correctOrder": ["Paso correcto 1", "Paso correcto 2", ...],
      "feedback": "Explicación del orden correcto",
      "difficulty": 0.7
    },
    {
      "type": "matching",
      "statement": "Relaciona cada concepto con su descripción correcta",
      "leftColumn": ["Concepto A", "Concepto B", "Concepto C", "Concepto D"],
      "rightColumn": ["Descripción 1", "Descripción 2", "Descripción 3", "Descripción 4"],
      "correctMatches": {
        "Concepto A": "Descripción correcta A",
        "Concepto B": "Descripción correcta B",
        "Concepto C": "Descripción correcta C",
        "Concepto D": "Descripción correcta D"
      },
      "feedback": "Explicación de las relaciones correctas",
      "difficulty": 0.7
    }
  ]
}

**IMPORTANTE**: 
- NO uses ejemplos de programación en ejercicios de matching o block_order
- Los ejercicios de matching deben relacionar conceptos del tema actual
- Los ejercicios de block_order deben ordenar pasos, fases o conceptos del tema
''';
  }

  String _getDifficultyGuidance(double theta) {
    if (theta < -0.5) {
      return '''
**Nivel: Básico** (θ < -0.5)
- Ejercicios simples y directos
- Enfócate en conceptos fundamentales
- Usa ejemplos concretos y familiares
- Dificultad recomendada: 0.3 - 0.5
''';
    } else if (theta < 0.5) {
      return '''
**Nivel: Intermedio** (-0.5 ≤ θ < 0.5)
- Ejercicios que requieren aplicar conceptos
- Combina múltiples ideas
- Introduce casos con ligera complejidad
- Dificultad recomendada: 0.5 - 0.7
''';
    } else {
      return '''
**Nivel: Avanzado** (θ ≥ 0.5)
- Ejercicios desafiantes y complejos
- Requiere pensamiento crítico y análisis
- Casos edge y optimizaciones
- Dificultad recomendada: 0.7 - 0.9
''';
    }
  }
}

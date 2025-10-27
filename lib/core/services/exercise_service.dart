import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/util/json_parser.dart';

class ExerciseService {
  final GeminiService _geminiService = GeminiService();

  Future<List<Exercise>> generateExercises({
    required String subtopic,
    required String description,
    required double currentTheta,
    required List<String> objectives,
    int count = 5,
    bool isReinforcement = false,
  }) async {
    final prompt = _buildExercisePrompt(
      subtopic: subtopic,
      description: description,
      currentTheta: currentTheta,
      objectives: objectives,
      count: count,
      isReinforcement: isReinforcement,
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

  /// Genera ejercicios de refuerzo basados en conceptos donde el usuario falló
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
  }) {
    final difficultyGuidance = _getDifficultyGuidance(currentTheta);
    final reinforcementNote = isReinforcement
        ? '\n**IMPORTANTE**: Estos son ejercicios de REFUERZO. Enfócate en los conceptos específicos donde el estudiante tuvo dificultades.'
        : '';

    return '''
Genera $count ejercicios dinámicos para el subtema "$subtopic".
Descripción: $description
Nivel de conocimiento del estudiante (θ): $currentTheta

$difficultyGuidance$reinforcementNote

Objetivos de aprendizaje:
${objectives.map((o) => '- $o').join('\n')}

**Tipos de ejercicios a incluir**:
1. **multiple_choice**: Preguntas con 4 opciones, una correcta.
2. **block_order**: Ordenar elementos (código, conceptos, pasos) en el orden correcto.
3. **code**: Completar o escribir código según el enunciado. Si el $subtopic

**Estructura JSON esperada**:
{
  "subtopic": "$subtopic",
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
      "statement": "Instrucción para ordenar elementos",
      "blocks": ["Elemento 1", "Elemento 2", "Elemento 3", "Elemento 4"],
      "correctOrder": ["Elemento correcto 1", "Elemento correcto 2", ...],
      "feedback": "Explicación del orden correcto",
      "difficulty": 0.7
    },
    {
      "type": "code",
      "statement": "Descripción del código a escribir",
      "initialCode": "// Código de inicio (opcional)",
      "correctCode": "código de solución",
      "hints": ["Pista 1", "Pista 2"],
      "feedback": "Explicación de la solución",
      "difficulty": 0.8
    }
  ]
}

**Requisitos**:
- Varía los tipos de ejercicios
- Ajusta la dificultad según el θ del estudiante
- Incluye retroalimentación educativa
- Asegúrate de que los ejercicios sean claros y verificables
- Devuelve SOLO el JSON, sin texto adicional

Genera los ejercicios ahora. No agregues texto adicional fuera del JSON. La respuesta debe ser únicamente el JSON.
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

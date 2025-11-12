import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/util/json_parser.dart';

class ExerciseService {
  final GeminiService _geminiService = GeminiService();

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

  Future<TheoryContent> generateTheoryContent({
    required String subtopic,
    required String description,
    required List<String> objectives,
    required double currentTheta,
  }) async {
    final prompt = _buildTheoryPrompt(
      subtopic: subtopic,
      description: description,
      objectives: objectives,
      currentTheta: currentTheta,
    );

    try {
      final result = await _geminiService.generateText(prompt);

      final jsonData = JsonParserUtil.parseJsonObject(result);

      if (!jsonData.containsKey('introduction')) {}

      final theoryContent = TheoryContent.fromJson(jsonData);

      return theoryContent;
    } catch (e) {
      return TheoryContent(
        introduction:
            'En esta sección aprenderás sobre $subtopic. $description',
        sections: [
          TheorySection(
            title: 'Concepto Principal',
            content:
                'El tema de $subtopic es fundamental para tu aprendizaje. '
                'Estudiaremos los aspectos clave y su aplicación práctica.',
          ),
        ],
        keyPoints: objectives,
        examples: ['Consulta documentación oficial u otros recursos.'],
      );
    }
  }

  String _buildTheoryPrompt({
    required String subtopic,
    required String description,
    required List<String> objectives,
    required double currentTheta,
  }) {
    final difficultyLevel = _getDifficultyLevel(currentTheta);

    return '''
Genera contenido teórico educativo para el siguiente tema:

**Subtema**: $subtopic
**Descripción**: $description
**Nivel del estudiante (θ)**: $currentTheta ($difficultyLevel)

**Objetivos de aprendizaje**:
${objectives.map((o) => '- $o').join('\n')}

Crea un contenido teórico estructurado que cubra:

1. **Introduction**: Una introducción clara y motivadora del tema (1 párrafo bien explicado)
2. **Sections**: Entre 2-4 secciones temáticas, cada una con:
   - title: Título de la sección
   - content: Explicación detallada del concepto (1-2 párrafos)
3. **KeyPoints**: 4-6 puntos clave que el estudiante debe recordar
4. **Examples**: 2-3 ejemplos prácticos concretos

**Consideraciones importantes**:
- Adapta la complejidad al nivel del estudiante ($difficultyLevel)
- Usa un lenguaje claro y directo
- Incluye analogías cuando sea apropiado
- Si es un tema de programación, incluye ejemplos de código
- SOLO SI ES UN TEMA DE PROGRAMACION INCLUYE EJEMPLOS DE CODIGO, SINO NO LOS INCLUYAS
- Relaciona el contenido con los objetivos de aprendizaje
- No uses markdown ni formato especial en el texto ni en los ejercicios

**Estructura JSON esperada**:
{
  "introduction": "Introducción al tema...",
  "sections": [
    {
      "title": "Título de la sección",
      "content": "Contenido detallado de la sección..."
    }
  ],
  "keyPoints": [
    "Punto clave 1",
    "Punto clave 2"
  ],
  "examples": [
    "Ejemplo práctico 1",
    "Ejemplo práctico 2"
  ]
}

Devuelve SOLO el JSON, sin texto adicional.
''';
  }

  String _getDifficultyLevel(double theta) {
    if (theta < -0.5) return 'Básico';
    if (theta < 0.5) return 'Intermedio';
    return 'Avanzado';
  }

  Future<List<Exercise>> generateExercises({
    required String subtopic,
    required String description,
    required double currentTheta,
    required List<String> objectives,
    required TheoryContent theoryContent,
    int count = 5,
    bool isReinforcement = false,
  }) async {
    final isProgramming = _isProgrammingTopic(subtopic, description);

    final prompt = _buildExercisePrompt(
      subtopic: subtopic,
      description: description,
      currentTheta: currentTheta,
      objectives: objectives,
      theoryContent: theoryContent,
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

  String _buildExercisePrompt({
    required String subtopic,
    required String description,
    required double currentTheta,
    required List<String> objectives,
    required TheoryContent theoryContent,
    required int count,
    required bool isReinforcement,
    required bool isProgramming,
  }) {
    final difficultyGuidance = _getDifficultyGuidance(currentTheta);
    final reinforcementNote = isReinforcement
        ? '\n**IMPORTANTE**: Estos son ejercicios de REFUERZO. Enfócate en los conceptos específicos donde el estudiante tuvo dificultades.'
        : '';

    final exerciseTypes = isProgramming
        ? _getProgrammingExerciseTypes()
        : _getGeneralExerciseTypes();

    final theoryContext =
        '''
**CONTEXTO TEÓRICO**:
El estudiante acaba de revisar la siguiente teoría:

Introducción: ${theoryContent.introduction}

Puntos clave aprendidos:
${theoryContent.keyPoints.map((p) => '- $p').join('\n')}

Ejemplos vistos:
${theoryContent.examples.map((e) => '- $e').join('\n')}
''';

    return '''
Genera $count ejercicios dinámicos para el subtema "$subtopic".

$theoryContext

Descripción: $description
Nivel de conocimiento del estudiante (θ): $currentTheta

$difficultyGuidance$reinforcementNote

Objetivos de aprendizaje:
${objectives.map((o) => '- $o').join('\n')}

$exerciseTypes

**CRÍTICO**: Los ejercicios deben estar DIRECTAMENTE relacionados con la teoría proporcionada:
- Usa los conceptos explicados en las secciones teóricas
- Referencias los puntos clave mencionados
- Aplica los ejemplos dados o crea variaciones de ellos
- Asegúrate de que si el estudiante entendió la teoría, pueda resolver los ejercicios

**Requisitos**:
- Varía los tipos de ejercicios
- Ajusta la dificultad según el θ del estudiante
- Incluye retroalimentación educativa que conecte con la teoría
- Asegúrate de que los ejercicios sean claros y verificables
- Devuelve SOLO el JSON, sin texto adicional

Genera los ejercicios ahora.
''';
  }

  String _getProgrammingExerciseTypes() {
    return '''
Tipos de ejercicios a incluir:
1. multiple_choice: Preguntas con 4 opciones, una correcta.
2. block_order: Ordenar líneas de código o pasos de un algoritmo en el orden correcto.
3. code: Analizar un fragmento de código y seleccionar cuál será su salida/resultado.
4. matching: Relacionar funciones o conceptos de programación con sus descripciones o usos correctos.

**REGLAS ESTRICTAS PARA EL FEEDBACK**:
- No uses palabras como: "Correcto", "Incorrecto", "Bien hecho", "Excelente", "Fallaste", "Respuesta correcta", "Respuesta incorrecta" ni sinónimos.
- El feedback debe ser **solo una explicación breve y neutral** basada en la teoría o el razonamiento detrás de la respuesta.
- No evalúes el desempeño del estudiante ni uses expresiones de aprobación o desaprobación.
- Ejemplo válido: "La opción elegida refleja el concepto principal descrito en la teoría."
- Ejemplo inválido: "Correcto, elegiste la respuesta adecuada."
- Limítate a explicar **por qué** la respuesta es válida o no, de forma objetiva y educativa.

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
    },
    {
      "type": "matching",
      "statement": "Relaciona cada función con su descripción correcta",
      "leftColumn": ["Función A", "Función B", "Función C", "Función D"],
      "rightColumn": ["Descripción 1", "Descripción 2", "Descripción 3", "Descripción 4"],
      "correctMatches": {
        "Función A": "Descripción correcta A",
        "Función B": "Descripción correcta B",
        "Función C": "Descripción correcta C",
        "Función D": "Descripción correcta D"
      },
      "feedback": "Explicación de las relaciones correctas",
      "difficulty": 0.7
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

**REGLAS ESTRICTAS PARA EL FEEDBACK**:
- No uses palabras como: "Correcto", "Incorrecto", "Bien hecho", "Excelente", "Fallaste", "Respuesta correcta", "Respuesta incorrecta" ni sinónimos.
- El feedback debe ser **solo una explicación breve y neutral** basada en la teoría o el razonamiento detrás de la respuesta.
- No evalúes el desempeño del estudiante ni uses expresiones de aprobación o desaprobación.
- Ejemplo válido: "La opción elegida refleja el concepto principal descrito en la teoría."
- Ejemplo inválido: "Correcto, elegiste la respuesta adecuada."
- Limítate a explicar **por qué** la respuesta es válida o no, de forma objetiva y educativa.

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

  Future<List<Exercise>> generateReinforcementExercises({
    required String subtopic,
    required List<String> failedConcepts,
    required double currentTheta,
  }) async {
    final simpleTheory = TheoryContent(
      introduction:
          'Vamos a reforzar los conceptos en los que tuviste dificultades.',
      sections: [],
      keyPoints: failedConcepts,
      examples: [],
    );

    return generateExercises(
      subtopic: subtopic,
      description: 'Refuerzo en: ${failedConcepts.join(", ")}',
      currentTheta: currentTheta,
      objectives: failedConcepts,
      theoryContent: simpleTheory,
      count: 3,
      isReinforcement: true,
    );
  }
}

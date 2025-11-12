import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/util/json_parser.dart';

class ExerciseService {
  final GeminiService _geminiService = GeminiService();

  //check if topic is programming related
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
**TIPOS DE EJERCICIOS PARA TEMAS DE PROGRAMACIÓN**:

1. **multiple_choice**: Preguntas conceptuales sobre programación (SIN código en el statement)
2. **block_order**: Ordenar líneas de código o pasos de algoritmos
3. **code**: Analizar código y predecir su salida
4. **matching**: Relacionar conceptos/funciones con sus descripciones

---

### Instrucciones:
1. Si el tema es sobre **Angular**, usa **Angular 20 o superior**.  
   - Usa terminología, sintaxis, y características reales de Angular 20 (Standalone Components, Signals, deferred loading, control flow syntax, etc.).
   - No menciones versiones anteriores.
   - Si dudas, responde como si Angular 20 fuera la versión actual estable.

---

**🚫 REGLAS CRÍTICAS SOBRE CÓDIGO EN EL STATEMENT 🚫**

LEE ESTO CUIDADOSAMENTE Y SÍGUELO AL PIE DE LA LETRA:

1. **Para ejercicios tipo "multiple_choice"**:
   - El campo "statement" NUNCA debe contener código
   - El campo "statement" NUNCA debe contener ejemplos de código
   - El campo "statement" NUNCA debe contener fragmentos de código
   - El campo "statement" NUNCA debe contener sintaxis de programación
   - El campo "statement" debe ser SOLO texto descriptivo y conceptual
   
   ❌ MAL: "statement": "¿Qué imprime este código? console.log('hola')"
   ✅ BIEN: "statement": "¿Cuál es la forma correcta de imprimir en consola en JavaScript?"

2. **Para ejercicios tipo "block_order"**:
   - El campo "statement" debe ser solo la instrucción
   - El código va en el campo "blocks"
   
   ❌ MAL: "statement": "Ordena este código: let x = 5"
   ✅ BIEN: "statement": "Ordena las siguientes líneas de código correctamente"

3. **Para ejercicios tipo "code"**:
   - El campo "statement" debe ser solo la pregunta
   - TODO el código va en el campo "codeSnippet"
   
   ❌ MAL: "statement": "function sum(a,b) { return a+b } ¿Cuál es la salida?"
   ✅ BIEN: "statement": "¿Cuál será la salida de este código?"
             "codeSnippet": "function sum(a,b) { return a+b }..."

4. **Para ejercicios tipo "matching"**:
   - El campo "statement" solo describe la tarea
   - Los conceptos de código van en "leftColumn" o "rightColumn"

---

**REGLAS PARA EL FEEDBACK**:
- No uses palabras evaluativas: "Correcto", "Incorrecto", "Bien", "Mal", "Excelente", "Fallaste"
- El feedback debe ser neutral y educativo
- Explica el razonamiento detrás de la respuesta
- Ejemplo válido: "Esta opción refleja el concepto de scope en JavaScript"
- Ejemplo inválido: "¡Correcto! Elegiste la respuesta adecuada"

---

**ESTRUCTURA JSON ESPERADA**:
{
  "subtopic": "nombre del tema",
  "exercises": [
    {
      "type": "multiple_choice",
      "statement": "¿Cuál es la función principal de un closure en JavaScript?",
      "options": [
        "Encapsular variables privadas",
        "Ejecutar código asíncrono",
        "Crear clases",
        "Manejar errores"
      ],
      "correctAnswer": "Encapsular variables privadas",
      "feedback": "Los closures permiten a una función acceder a variables de su scope externo incluso después de que la función externa haya terminado",
      "difficulty": 0.6
    },
    {
      "type": "block_order",
      "statement": "Ordena las líneas para crear una función que sume dos números",
      "blocks": [
        "function suma(a, b) {",
        "  return a + b;",
        "}",
        "console.log(suma(5, 3));"
      ],
      "correctOrder": [
        "function suma(a, b) {",
        "  return a + b;",
        "}",
        "console.log(suma(5, 3));"
      ],
      "feedback": "La estructura correcta define primero la función y luego la invoca",
      "difficulty": 0.5
    },
    {
      "type": "code",
      "statement": "¿Cuál será la salida de este código?",
      "codeSnippet": "let x = 5;\\nlet y = x++;\\nconsole.log(y);",
      "outputOptions": ["4", "5", "6", "undefined"],
      "correctAnswer": "5",
      "hints": [
        "El operador ++ puede ser prefijo o sufijo",
        "x++ retorna el valor antes de incrementar"
      ],
      "feedback": "El operador sufijo ++ retorna el valor original antes de incrementarlo, por lo que y recibe 5 y luego x se convierte en 6",
      "difficulty": 0.7
    },
    {
      "type": "matching",
      "statement": "Relaciona cada método de array con su función",
      "leftColumn": ["map", "filter", "reduce", "forEach"],
      "rightColumn": [
        "Ejecuta una función para cada elemento sin retornar",
        "Transforma cada elemento y retorna un nuevo array",
        "Filtra elementos según una condición",
        "Acumula valores en un resultado único"
      ],
      "correctMatches": {
        "map": "Transforma cada elemento y retorna un nuevo array",
        "filter": "Filtra elementos según una condición",
        "reduce": "Acumula valores en un resultado único",
        "forEach": "Ejecuta una función para cada elemento sin retornar"
      },
      "feedback": "Cada método tiene un propósito específico en la manipulación de arrays",
      "difficulty": 0.6
    }
  ]
}

**RECUERDA**: 
- El statement NUNCA debe contener código en ejercicios multiple_choice
- El statement NUNCA debe contener código en ejercicios matching
- Si necesitas mostrar código, usa el tipo "code" con el campo "codeSnippet"
''';
  }

  String _getGeneralExerciseTypes() {
    return '''
**TIPOS DE EJERCICIOS PARA TEMAS NO PROGRAMACIÓN**:

1. **multiple_choice**: Preguntas conceptuales con 4 opciones
2. **block_order**: Ordenar pasos, procesos o secuencias lógicas
3. **matching**: Relacionar conceptos con definiciones o características

---

**🚫 REGLAS CRÍTICAS PARA TEMAS NO PROGRAMACIÓN 🚫**

IMPORTANTE: Este NO es un tema de programación, por lo tanto:

1. **NO incluyas ningún ejercicio de tipo "code"**
2. **NO incluyas código en ningún campo**
3. **NO uses sintaxis de programación**
4. **NO uses ejemplos de código**
5. **NO menciones lenguajes de programación**

El campo "statement" debe contener SOLO:
- Preguntas conceptuales claras
- Instrucciones en lenguaje natural
- Descripciones sin formato técnico

---

**REGLAS PARA EL FEEDBACK**:
- No uses palabras evaluativas: "Correcto", "Incorrecto", "Bien", "Mal", "Excelente", "Fallaste"
- El feedback debe ser neutral y educativo
- Explica el razonamiento detrás de la respuesta
- Ejemplo válido: "Esta opción refleja el concepto principal descrito en la teoría"
- Ejemplo inválido: "¡Correcto! Elegiste la respuesta adecuada"

---

**ESTRUCTURA JSON ESPERADA**:
{
  "subtopic": "nombre del tema",
  "exercises": [
    {
      "type": "multiple_choice",
      "statement": "¿Cuál es la principal característica del método científico?",
      "options": [
        "La observación sistemática de fenómenos",
        "El uso de instrumentos tecnológicos",
        "La publicación de resultados",
        "El trabajo en laboratorio"
      ],
      "correctAnswer": "La observación sistemática de fenómenos",
      "feedback": "El método científico se basa fundamentalmente en la observación controlada y sistemática para generar conocimiento",
      "difficulty": 0.5
    },
    {
      "type": "block_order",
      "statement": "Ordena las etapas del ciclo del agua",
      "blocks": [
        "Evaporación del agua de océanos y ríos",
        "Condensación en las nubes",
        "Precipitación en forma de lluvia",
        "Infiltración en el suelo"
      ],
      "correctOrder": [
        "Evaporación del agua de océanos y ríos",
        "Condensación en las nubes",
        "Precipitación en forma de lluvia",
        "Infiltración en el suelo"
      ],
      "feedback": "El ciclo del agua sigue un proceso continuo desde la evaporación hasta el retorno al suelo",
      "difficulty": 0.6
    },
    {
      "type": "matching",
      "statement": "Relaciona cada ecosistema con su característica principal",
      "leftColumn": [
        "Bosque tropical",
        "Desierto",
        "Tundra",
        "Sabana"
      ],
      "rightColumn": [
        "Temperaturas extremadamente bajas",
        "Alta biodiversidad y humedad",
        "Escasez de precipitaciones",
        "Pastizales con árboles dispersos"
      ],
      "correctMatches": {
        "Bosque tropical": "Alta biodiversidad y humedad",
        "Desierto": "Escasez de precipitaciones",
        "Tundra": "Temperaturas extremadamente bajas",
        "Sabana": "Pastizales con árboles dispersos"
      },
      "feedback": "Cada ecosistema tiene características únicas determinadas por clima y geografía",
      "difficulty": 0.7
    }
  ]
}

**RECUERDA**: 
- Este NO es un tema de programación
- NO incluyas código en ningún campo
- NO uses ejercicios tipo "code"
- Usa lenguaje natural y conceptual
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

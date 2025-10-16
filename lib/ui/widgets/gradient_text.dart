import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/ui/screens/main_app/test_screen.dart';

// Componente GradientText
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

class LearnTestScreen extends StatefulWidget {
  const LearnTestScreen({super.key});

  @override
  State<LearnTestScreen> createState() => _LearnTestScreenState();
}

class _LearnTestScreenState extends State<LearnTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _loading = false;
  Map<String, dynamic>? _parsedJson;

  Future<void> _generateTest() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _loading = true;
      _parsedJson = null; // ✅ Limpiar la card anterior
    });

    final prompt =
        '''
Genera un cuestionario en formato JSON sobre "$topic".
Debe tener entre 10 y 15 preguntas.
La estructura del JSON debe ser un objeto con una clave "preguntas" que contenga una lista de objetos.
Cada objeto de pregunta debe tener:
- "question": texto de la pregunta
- "options": lista de 4 respuestas posibles
- "answer": la respuesta correcta
No agregues texto adicional fuera del JSON. La respuesta debe ser únicamente el JSON.
''';

    try {
      final result = await _geminiService.generateText(prompt);

      String jsonString;

      if (result.contains("```json")) {
        final startIndex = result.indexOf("```json") + 7;
        final endIndex = result.lastIndexOf("```");
        if (endIndex > startIndex) {
          jsonString = result.substring(startIndex, endIndex);
        } else {
          jsonString = result.substring(result.indexOf('{'));
        }
      } else if (result.contains("{") || result.contains("[")) {
        final isArray = result.trim().startsWith('[');
        final startIndex = isArray ? result.indexOf('[') : result.indexOf('{');
        final endIndex = isArray
            ? result.lastIndexOf(']')
            : result.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          jsonString = result.substring(startIndex, endIndex + 1);
        } else {
          throw const FormatException(
            "No se encontró un JSON válido en la respuesta.",
          );
        }
      } else {
        throw const FormatException(
          "La respuesta no contiene un formato JSON reconocible.",
        );
      }

      final jsonData = jsonDecode(jsonString.trim());

      setState(() {
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('preguntas')) {
          _parsedJson = {"topic": topic, "questions": jsonData['preguntas']};
        } else if (jsonData is List) {
          _parsedJson = {"topic": topic, "questions": jsonData};
        } else {
          throw const FormatException("El formato del JSON no es el esperado.");
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al procesar la respuesta: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _loading;

    return FadeInUp(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Título con componente GradientText
                  GradientText(
                    "¿Qué quieres aprender?",
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                    ),
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input
                  TextField(
                    controller: _controller,
                    enabled: !isDisabled,
                    style: TextStyle(color: Colors.grey[800]),
                    decoration: InputDecoration(
                      hintText: "Ejemplo: Signals en Angular",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(
                        Icons.school,
                        color: Colors.blueAccent,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (!isDisabled && value.isNotEmpty) {
                        _generateTest();
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // ✅ Botón mejorado
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isDisabled ? null : _generateTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        disabledBackgroundColor: Colors.blueAccent.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isDisabled ? 0 : 2,
                      ),
                      child: _loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Generando test...",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Generar Test",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Vista previa del test con animación de salida
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _parsedJson != null
                        ? _TestPreviewCard(
                            key: ValueKey(_parsedJson!["topic"]),
                            parsedJson: _parsedJson!,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Widget separado para la card de preview
class _TestPreviewCard extends StatelessWidget {
  const _TestPreviewCard({super.key, required this.parsedJson});

  final Map<String, dynamic> parsedJson;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    parsedJson["topic"],
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(parsedJson["questions"] as List)
                .take(3)
                .map(
                  (q) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q['question'],
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if ((parsedJson["questions"] as List).length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "...y ${(parsedJson["questions"] as List).length - 3} preguntas más",
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TestScreen(data: parsedJson),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  "Comenzar Test",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

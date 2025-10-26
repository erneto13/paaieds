import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/user.dart';
import 'package:paaieds/ui/screens/main_app/test_screen.dart';
import 'package:paaieds/ui/widgets/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/gradient_text.dart';
import 'package:paaieds/ui/widgets/snackbar.dart';
import 'package:paaieds/util/json_parser.dart';
import '../../../api/gemini_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/test_preview_card.dart';

class LearnTestScreen extends StatefulWidget {
  final UserModel user;
  final Function(int)? onNavBarTap;
  final int? currentIndex;

  const LearnTestScreen({
    super.key,
    required this.user,
    this.onNavBarTap,
    this.currentIndex,
  });

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
      _parsedJson = null;
    });

    final prompt = _buildPrompt(topic);

    try {
      final result = await _geminiService.generateText(prompt);
      final jsonData = JsonParserUtil.parseJsonFlexible(
        result,
        preferredKey: 'preguntas',
      );

      setState(() {
        _parsedJson = {"topic": topic, "questions": jsonData};
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      CustomSnackbar.showError(
        context: context,
        message: 'Ha ocurrido un error',
        description: 'Error al procesar la respuesta, intentar más tarde.',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String _buildPrompt(String topic) {
    return '''
Genera un cuestionario en formato JSON sobre "$topic".
Debe tener entre 8 y 10 preguntas.
La estructura del JSON debe ser un objeto con una clave "preguntas" que contenga una lista de objetos.
Cada objeto de pregunta debe tener:
- "question": texto de la pregunta
- "options": lista de 4 respuestas posibles
- "answer": la respuesta correcta
No agregues texto adicional fuera del JSON. La respuesta debe ser únicamente el JSON.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Hola, ${widget.user.displayName}",
        onProfileTap: () {},
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Sección superior
            Expanded(
              flex: 2, // Ajusta este valor para el tamaño
              child: Container(
                color: Colors.blue[50], // 👈 Color de fondo superior
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: GradientText(
                        "¿Qué quieres aprender?",
                        gradient: const LinearGradient(
                          colors: [AppColors.deepBlue, AppColors.oceanBlue],
                        ),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildTextField(_loading),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildGenerateButton(_loading),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Sección inferior
            Expanded(
              flex: 3, // Ajusta este valor también
              child: Container(
                color: Colors.grey[100], // 👈 Color de fondo inferior
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                child: Center(
                  child: _parsedJson == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          height: 200,
                          alignment: Alignment.center,
                          child: Text(
                            "Aquí aparecerá tu test generado",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : _buildTestPreview(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onNavBarTap != null
          ? CustomBottomNavBar(
              currentIndex: widget.currentIndex ?? 0,
              onTap: widget.onNavBarTap!,
            )
          : null,
    );
  }

  Widget _buildTextField(bool isDisabled) {
    return TextField(
      controller: _controller,
      enabled: !isDisabled,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        hintText: "Ejemplo: Signals en Angular",
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.school, color: AppColors.deepBlue),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: AppColors.lightBlue.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.highlight, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      onSubmitted: (value) {
        if (isDisabled && value.isEmpty) {
          CustomSnackbar.showError(
            context: context,
            message: 'Ha ocurrido un error',
            description:
                'Debes esperar a que el contenido anterior sea generado.',
          );
        } else {
          _generateTest();
        }
      },
    );
  }

  Widget _buildGenerateButton(bool isDisabled) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_controller.text.trim().isEmpty) {
            CustomSnackbar.showError(
              context: context,
              message: 'Ha ocurrido un error',
              description: 'Por favor, ingresa un  tema para generar el test.',
            );
            return;
          }
          isDisabled ? null : _generateTest();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundButtom,
          disabledBackgroundColor: AppColors.lightBlue.withValues(alpha: 0.5),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Text(
                "Generar Test",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildTestPreview() {
    if (_parsedJson == null) {
      return const SizedBox.shrink();
    }

    return SlideInUp(
      key: ValueKey(_parsedJson!["topic"]),
      duration: const Duration(milliseconds: 400),
      child: TestPreviewCard(
        parsedJson: _parsedJson!,
        onStartTest: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TestScreen(data: _parsedJson!)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

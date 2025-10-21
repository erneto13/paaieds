import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/screens/main_app/test_screen.dart';
import 'package:paaieds/ui/widgets/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/gradient_text.dart';
import 'package:paaieds/util/json_parser.dart';
import '../../../api/gemini_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/test_preview_card.dart';

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
  int _selectedIndex = 0;

  Future<void> _generateTest() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _loading = true;
      _parsedJson =
          null; // Oculta la tarjeta anterior mientras se genera una nueva
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
      _showErrorSnackBar(e.toString());
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al procesar la respuesta: $message"),
        backgroundColor: AppColors.oceanBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _loading;

    // Ya no envolvemos el Scaffold en FadeInUp
    return Scaffold(
      appBar: CustomAppBar(title: "test", onProfileTap: () => {}),
      backgroundColor: Colors.white10,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- ANIMACIÓN AÑADIDA ---
                    FadeInDown(
                      duration: const Duration(milliseconds: 300),
                      child: _buildAIPoweredLabel(),
                    ),
                    const SizedBox(height: 20),
                    // --- ANIMACIÓN AÑADIDA ---
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: GradientText(
                        "¿Qué quieres aprender?",
                        gradient: const LinearGradient(
                          colors: [AppColors.deepBlue, AppColors.oceanBlue],
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // --- ANIMACIÓN AÑADIDA ---
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildTextField(isDisabled),
                    ),
                    const SizedBox(height: 20),
                    // --- ANIMACIÓN AÑADIDA ---
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildGenerateButton(isDisabled),
                    ),
                    const SizedBox(height: 30),
                    // Este método ahora contiene la animación de animate_do
                    _buildTestPreview(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildTextField(bool isDisabled) {
    // ... (sin cambios en este método)
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
        if (!isDisabled && value.isNotEmpty) {
          _generateTest();
        }
      },
    );
  }

  Widget _buildGenerateButton(bool isDisabled) {
    // ... (sin cambios en este método)
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _generateTest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
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
    );
  }

  // --- MÉTODO ACTUALIZADO ---
  Widget _buildTestPreview() {
    // Si no hay JSON, no mostramos nada.
    if (_parsedJson == null) {
      return const SizedBox.shrink();
    }

    // Usamos SlideInUp de animate_do para que la tarjeta aparezca desde abajo.
    // Usamos la Key para que Flutter sepa que es un widget nuevo si el topic cambia.
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

  Widget _buildAIPoweredLabel() {
    // ... (sin cambios en este método)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.oceanBlue.withValues(alpha: 0.3),
            AppColors.deepBlue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.deepBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.deepBlue),
          const SizedBox(width: 6),
          Text(
            "Potenciado con IA",
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.deepBlue,
            ),
          ),
        ],
      ),
    );
  }
}

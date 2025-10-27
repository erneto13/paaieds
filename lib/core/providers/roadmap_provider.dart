import 'package:flutter/foundation.dart';
import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/services/user_service.dart';
import 'package:paaieds/util/json_parser.dart';

class RoadmapProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final UserService _userService = UserService();

  Roadmap? _currentRoadmap;
  List<Roadmap> _userRoadmaps = [];
  bool _isLoading = false;
  String? _errorMessage;

  Roadmap? get currentRoadmap => _currentRoadmap;
  List<Roadmap> get userRoadmaps => _userRoadmaps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //genera un roadmap basado en los resultados del diagnóstico
  Future<bool> generateRoadmap({
    required String userId,
    required String topic,
    required String level,
    required double theta,
    required double percentage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prompt = _buildRoadmapPrompt(
        topic: topic,
        level: level,
        percentage: percentage,
      );

      final result = await _geminiService.generateText(prompt);
      final jsonData = JsonParserUtil.parseJsonObject(result);

      final sectionsData = jsonData['sections'] as List<dynamic>? ?? [];
      final sections = sectionsData
          .asMap()
          .entries
          .map(
            (entry) => RoadmapSection.fromJson(
              entry.value as Map<String, dynamic>,
              entry.key,
            ),
          )
          .toList();

      final roadmap = Roadmap(
        id: '',
        topic: topic,
        level: level,
        initialTheta: theta,
        sections: sections,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final roadmapId = await _userService.saveRoadmap(
        uid: userId,
        roadmap: roadmap,
      );

      if (roadmapId == null) {
        throw Exception('Failed to save roadmap to Firestore');
      }

      //actualiza el roadmap actual con el ID asignado
      _currentRoadmap = Roadmap(
        id: roadmapId,
        topic: roadmap.topic,
        level: roadmap.level,
        initialTheta: roadmap.initialTheta,
        sections: roadmap.sections,
        createdAt: roadmap.createdAt,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error generating roadmap: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _buildRoadmapPrompt({
    required String topic,
    required String level,
    required double percentage,
  }) {
    return '''
Genera una hoja de ruta de aprendizaje adaptativo para el tema "$topic" basada en un nivel de conocimiento estimado del $percentage% (Nivel: $level).
Crea un objeto JSON con una matriz "sections". Cada sección debe incluir:
- bloomLevel: Nivel de la taxonomía de Bloom ("Recordar", "Comprender", "Aplicar", "Analizar", "Evaluar", "Crear")
- subtopic: nombre del subtema
- description: breve descripción de lo que se aprenderá
- baseDifficulty: dificultad base («baja», «media», «alta»)
- objectives: matriz de objetivos de aprendizaje (cadenas)
Importante:
- Para el nivel «Básico» ($percentage < 50 %): comience con los niveles «Recordar» y «Comprender», céntrese en los fundamentos
- Para el nivel «Intermedio» (50 % ≤ $percentage < 75 %): mezcle los niveles «Comprender», «Aplicar» y «Analizar»
- Para el nivel «Avanzado» ($percentage ≥ 75 %): céntrate en los niveles «Analizar», «Evaluar» y «Crear».
- Crea entre 5 y 8 secciones progresivas.
- NO incluyas ejercicios todavía, solo la estructura de la hoja de ruta.
- Devuelve SOLO el objeto JSON, sin texto adicional.
Ejemplo de estructura:

Traducción realizada con la versión gratuita del traductor DeepL.com
{
  "secciones": [
    {
      "bloomLevel": "Comprender",
      "subtopic": "Ciclo de vida de los componentes",
      "description": "Comprender cómo Angular gestiona la inicialización y destrucción de componentes",
      "baseDifficulty": "media",
      "objectives": ["Identificar los ganchos del ciclo de vida", "Explicar el uso de ngOnInit"]
    }
  ]
}
''';
  }

  //czarga un roadmap específico
  Future<bool> loadRoadmap({
    required String userId,
    required String roadmapId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final roadmap = await _userService.getRoadmap(
        uid: userId,
        roadmapId: roadmapId,
      );

      if (roadmap == null) {
        throw Exception('Roadmap not found');
      }

      _currentRoadmap = roadmap;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error loading roadmap: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //carga todos los roadmaps del usuario
  Future<void> loadUserRoadmaps(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userRoadmaps = await _userService.getUserRoadmaps(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading roadmaps: $e';
      _userRoadmaps = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  //actualiza el estado de finalización de una sección del roadmap
  Future<bool> updateSectionCompletion({
    required String userId,
    required String sectionId,
    required bool completed,
    double? finalTheta,
  }) async {
    if (_currentRoadmap == null) return false;

    try {
      final success = await _userService.updateRoadmapSection(
        uid: userId,
        roadmapId: _currentRoadmap!.id,
        sectionId: sectionId,
        completed: completed,
        finalTheta: finalTheta,
      );

      if (!success) return false;

      final updatedSections = _currentRoadmap!.sections.map((section) {
        if (section.id == sectionId) {
          return section.copyWith(completed: completed, finalTheta: finalTheta);
        }
        return section;
      }).toList();

      _currentRoadmap = Roadmap(
        id: _currentRoadmap!.id,
        topic: _currentRoadmap!.topic,
        level: _currentRoadmap!.level,
        initialTheta: _currentRoadmap!.initialTheta,
        sections: updatedSections,
        createdAt: _currentRoadmap!.createdAt,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating section: $e';
      notifyListeners();
      return false;
    }
  }

  RoadmapSection? getNextSection() {
    if (_currentRoadmap == null) return null;

    try {
      return _currentRoadmap!.sections.firstWhere(
        (section) => !section.completed,
      );
    } catch (e) {
      return null;
    }
  }

  void setCurrentRoadmap(Roadmap roadmap) {
    _currentRoadmap = roadmap;
    notifyListeners();
  }

  Future<bool> deleteRoadmap({
    required String userId,
    required String roadmapId,
  }) async {
    try {
      final success = await _userService.deleteRoadmap(
        uid: userId,
        roadmapId: roadmapId,
      );

      if (success) {
        _userRoadmaps.removeWhere((r) => r.id == roadmapId);
        if (_currentRoadmap?.id == roadmapId) {
          _currentRoadmap = null;
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Error deleting roadmap: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _currentRoadmap = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

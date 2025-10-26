import 'package:flutter/foundation.dart';
import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/algorithm/irt_service.dart';
import 'package:paaieds/core/models/question.dart';
import 'package:paaieds/core/services/user_service.dart';
import 'package:paaieds/util/json_parser.dart';

//provider para manejar la generacion y evaluacion de tests
class TestProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final UserService _userService = UserService();

  List<QuestionModel> _questions = [];
  final Map<int, String> _selectedAnswers = {};
  String? _currentTopic;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _evaluationResults;

  List<QuestionModel> get questions => _questions;
  Map<int, String> get selectedAnswers => _selectedAnswers;
  String? get currentTopic => _currentTopic;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get evaluationResults => _evaluationResults;
  bool get allAnswered => _selectedAnswers.length == _questions.length;

  //genera un nuevo test basado en el tema
  Future<bool> generateTest(String topic) async {
    if (topic.trim().isEmpty) {
      _errorMessage = 'Debes ingresar un tema';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _currentTopic = topic;
    _questions.clear();
    _selectedAnswers.clear();
    _evaluationResults = null;
    notifyListeners();

    try {
      final prompt = _buildPrompt(topic);
      final result = await _geminiService.generateText(prompt);
      final jsonData = JsonParserUtil.parseJsonFlexible(
        result,
        preferredKey: 'preguntas',
      );

      _questions = jsonData.map((q) => QuestionModel.fromJson(q)).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al generar test: $e';
      _isLoading = false;
      notifyListeners();
      return false;
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

  //registra la respuesta del usuario a una pregunta
  void selectAnswer(int index, String answer) {
    _selectedAnswers[index] = answer;
    notifyListeners();
  }

  //evalua las respuestas del usuario usando irt
  Future<bool> evaluateTest(String userId) async {
    if (!allAnswered) {
      _errorMessage = 'Debes responder todas las preguntas';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Preparar las respuestas con detalles completos
      final responses = _questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        final userAnswer = _selectedAnswers[i] ?? '';
        final isCorrect = userAnswer == q.answer;

        return {
          'question': q.question,
          'options': q.options,
          'correctAnswer': q.answer,
          'userAnswer': userAnswer,
          'selected': userAnswer,
          'isCorrect': isCorrect,
        };
      }).toList();

      _evaluationResults = IRTService.evaluateAbility(responses: responses);

      //guardar resultado en firestore con las preguntas
      if (_currentTopic != null) {
        await _userService.saveAssessmentResult(
          uid: userId,
          topicName: _currentTopic!,
          evaluationResults: _evaluationResults!,
          questionsData: responses, 
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al evaluar test: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //reinicia el estado del provider para un nuevo test
  void reset() {
    _questions.clear();
    _selectedAnswers.clear();
    _currentTopic = null;
    _errorMessage = null;
    _evaluationResults = null;
    notifyListeners();
  }

  //limpia solo los mensajes de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

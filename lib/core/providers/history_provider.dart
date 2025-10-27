import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:paaieds/core/models/test_results.dart';
import 'package:paaieds/core/services/user_service.dart';

class HistoryProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<TestResult> _testHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<TestResult>>? _historySubscription;

  List<TestResult> get testHistory => _testHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadTestHistoryStream(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _historySubscription?.cancel();

    _historySubscription = _userService
        .userTestHistoryStream(userId)
        .listen(
          (testResults) {
            _testHistory = testResults;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Error al cargar historial: $error';
            _testHistory = [];
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> loadTestHistory(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final assessmentsData = await _userService.getUserAssessments(userId);

      _testHistory = assessmentsData.map((data) {
        return TestResult.fromMap(data, data['id'] ?? '');
      }).toList();
    } catch (e) {
      _errorMessage = 'Error al cargar historial: $e';
      _testHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //eliminar un resultado del historial
  Future<bool> deleteTestResult({
    required String userId,
    required String testId,
    required String topic,
  }) async {
    try {
      await _userService.deleteAssessmentResult(
        uid: userId,
        assessmentId: testId,
      );

      final roadmaps = await _userService.getUserRoadmaps(userId);
      dynamic roadmapToDelete;
      try {
        roadmapToDelete = roadmaps.firstWhere(
          (r) => r.topic.toLowerCase() == topic.toLowerCase(),
        );
      } catch (_) {
        roadmapToDelete = null;
      }

      if (roadmapToDelete != null) {
        await _userService.deleteRoadmap(
          uid: userId,
          roadmapId: roadmapToDelete.id,
        );
      }

      _testHistory.removeWhere((t) => t.id == testId);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el resultado o su roadmap: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }
}

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

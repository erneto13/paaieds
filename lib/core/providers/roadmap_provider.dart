import 'package:flutter/material.dart';
import 'package:paaieds/api/gemini_service.dart';
import 'package:paaieds/core/services/user_service.dart';

//provider para manejar la generacion de roadmaps
class RoadmapProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final UserService _userService = UserService();

  Future<bool> generateRoadmap(String topic, String theta) {
    

    return Future.value(true);
  }
}

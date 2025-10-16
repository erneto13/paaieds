import 'dart:convert';

class JsonParserUtil {
  static String extractJsonString(String response) {
    if (response.trim().isEmpty) {
      throw const FormatException("La respuesta está vacía.");
    }

    String jsonString;

    if (response.contains("```json")) {
      final startIndex = response.indexOf("```json") + 7;
      final endIndex = response.lastIndexOf("```");

      if (endIndex > startIndex) {
        jsonString = response.substring(startIndex, endIndex);
      } else {
        final fallbackStart = response.indexOf('{');
        if (fallbackStart != -1) {
          jsonString = response.substring(fallbackStart);
        } else {
          throw const FormatException("Bloque de código JSON mal formado.");
        }
      }
    } else if (response.contains("```")) {
      final startIndex = response.indexOf("```") + 3;
      final endIndex = response.lastIndexOf("```");

      if (endIndex > startIndex) {
        jsonString = response.substring(startIndex, endIndex).trim();
        if (jsonString.startsWith(RegExp(r'[a-zA-Z]+'))) {
          jsonString = jsonString.substring(jsonString.indexOf('\n') + 1);
        }
      } else {
        throw const FormatException("Bloque de código mal formado.");
      }
    } else if (response.contains("{") || response.contains("[")) {
      final isArray = response.trim().startsWith('[');
      final startIndex = isArray
          ? response.indexOf('[')
          : response.indexOf('{');
      final endIndex = isArray
          ? response.lastIndexOf(']')
          : response.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonString = response.substring(startIndex, endIndex + 1);
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

    return jsonString.trim();
  }

  static dynamic parseJson(String response) {
    final jsonString = extractJsonString(response);

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      throw FormatException("Error al decodificar JSON: ${e.toString()}");
    }
  }

  static Map<String, dynamic> parseJsonObject(
    String response, {
    String? requiredKey,
  }) {
    final jsonData = parseJson(response);

    if (jsonData is! Map<String, dynamic>) {
      throw const FormatException(
        "Se esperaba un objeto JSON pero se recibió otro tipo.",
      );
    }

    if (requiredKey != null && !jsonData.containsKey(requiredKey)) {
      throw FormatException(
        "El objeto JSON no contiene la clave requerida: '$requiredKey'",
      );
    }

    return jsonData;
  }

  static List<dynamic> parseJsonArray(String response) {
    final jsonData = parseJson(response);

    if (jsonData is! List) {
      throw const FormatException(
        "Se esperaba un array JSON pero se recibió otro tipo.",
      );
    }

    return jsonData;
  }

  static bool validateKeys(
    Map<String, dynamic> data,
    List<String> requiredKeys,
  ) {
    return requiredKeys.every((key) => data.containsKey(key));
  }

  static List<dynamic> parseJsonFlexible(
    String response, {
    String? preferredKey,
  }) {
    final jsonData = parseJson(response);

    if (jsonData is List) {
      return jsonData;
    }

    if (jsonData is Map<String, dynamic>) {
      if (preferredKey != null && jsonData.containsKey(preferredKey)) {
        final value = jsonData[preferredKey];
        if (value is List) {
          return value;
        }
      }

      for (final value in jsonData.values) {
        if (value is List) {
          return value;
        }
      }

      throw const FormatException("El objeto JSON no contiene ninguna lista.");
    }

    throw const FormatException("El JSON no es ni un objeto ni una lista.");
  }
}

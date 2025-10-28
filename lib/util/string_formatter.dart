extension TitleCaseExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;

    return split(' ')
        .map((word) {
          if (word.contains(RegExp(r'[A-Z]'))) return word;

          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

extension GetBloomDescription on String {
  String getBloomDescription() {
    String normalizedLevel = trim().toLowerCase();

    switch (normalizedLevel) {
      case "recordar":
        return "Recordar hechos y conceptos.";
      case "comprender":
        return "Explicar ideas o conceptos.";
      case "aplicar":
        return "Usar información en lo nuevo.";
      case "analizar":
        return "Descomponer y examinar partes.";
      case "evaluar":
        return "Justificar una decisión.";
      case "crear":
        return "Producir algo nuevo.";
      default:
        return "Descripción del nivel no disponible.";
    }
  }
}

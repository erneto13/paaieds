extension TitleCaseExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;

    return split(' ').map((word) {
      if (word.contains(RegExp(r'[A-Z]'))) return word;

      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

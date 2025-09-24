import 'package:flutter/material.dart';
import 'package:paaieds/ui/widgets/selection_option.dart';

class StepSpecialization extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onOptionSelected;

  const StepSpecialization({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso 1 de 2',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Qué área de Angular quieres reforzar o especializarte?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SelectionOption(
              text: option,
              isSelected: selectedOption == option,
              onTap: () => onOptionSelected(option),
            ),
          )),
        ],
      ),
    );
  }
}
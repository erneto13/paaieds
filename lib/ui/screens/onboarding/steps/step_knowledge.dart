import 'package:flutter/material.dart';

class StepKnowledge extends StatelessWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const StepKnowledge({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso 2 de 2',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Qué porcentaje de conocimiento consideras que tienes en esta área?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              '${initialValue.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: initialValue,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${initialValue.toInt()}%',
            activeColor: Colors.white,
            inactiveColor: const Color(0xFF3A5160),
            onChanged: onChanged,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
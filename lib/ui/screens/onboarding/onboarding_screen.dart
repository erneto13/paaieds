import 'package:flutter/material.dart';
import 'package:paaieds/ui/screens/main_app/home_screen.dart';
import 'package:paaieds/ui/widgets/primary_button.dart';

// Importa los pasos que crearemos a continuación
import 'steps/step_specialization.dart';
import 'steps/step_knowledge.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Datos piloto
  final List<String> _specializationOptions = [
    'Componentes y Vistas',
    'Servicios e Inyección de Dependencias',
    'Routing y Navegación',
    'Manejo de Formularios (Reactivos y Template-driven)',
    'RxJS y Programación Reactiva',
    'NgRx para Manejo de Estado',
  ];

  // Estado que guardará las selecciones del usuario
  String? _selectedSpecialization;
  double _knowledgeLevel = 50.0;

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentPage + 1) / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cuéntanos sobre ti'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2D3D41),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          StepSpecialization(
            options: _specializationOptions,
            selectedOption: _selectedSpecialization,
            onOptionSelected: (option) {
              setState(() {
                _selectedSpecialization = option;
              });
            },
          ),
          StepKnowledge(
            initialValue: _knowledgeLevel,
            onChanged: (value) {
              setState(() {
                _knowledgeLevel = value;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: PrimaryButton(
          text: _currentPage == 1 ? 'Finalizar' : 'Siguiente',
          onPressed: () {
            if (_currentPage == 0) {
              if (_selectedSpecialization != null) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                setState(() => _currentPage++);
              }
            } else {
              // Navegar a la pantalla principal y limpiar el historial
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:paaieds/core/models/course.dart';
import 'package:paaieds/ui/widgets/continue_learning_card.dart';
import 'package:paaieds/ui/widgets/gradient_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Course mainCourse = Course(
    title: 'Angular Avanzado',
    chapter: 'Capítulo 3: Goku ha fallecido',
    lessonsInfo: '10 Lecciones • 3 Quizzes',
    author: 'Freezer de Dragonbol',
    progress: 0.65,
    color: const Color.fromARGB(255, 173, 59, 68),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título gradiente centrado
            GradientText(
              '¿Qué te gustaría aprender hoy?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              gradient: const LinearGradient(
                colors: [Color(0xFF3184fe), Color(0xFF4b98fd)],
              ),
            ),
            const SizedBox(height: 20),

            // TextField debajo del título
            _buildSearchField(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pregunta lo que quieras aprender...',
          hintStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF8b8b8b)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white12,
      elevation: 0,
      leadingWidth: 80,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hola, Nine', style: TextStyle(fontSize: 14)),
          Text(
            'Miércoles, 24 de Sept.',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF2D3D41),
        boxShadow: [BoxShadow(blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2D3D41),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              label: 'Cursos',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showAction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showAction)
          Text(
            'Ver todos',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

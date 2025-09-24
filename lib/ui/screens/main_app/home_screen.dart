import 'package:flutter/material.dart';
import 'package:paaieds/core/models/course.dart'; // Si usas el modelo
import 'package:paaieds/ui/widgets/continue_learning_card.dart';
import 'package:paaieds/ui/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- DATOS PILOTO ---
  // Puedes reemplazar esto con datos de tu API/Base de datos
  final Course mainCourse = Course(
    title: 'Angular Avanzado',
    chapter: 'Capítulo 3: Goku ha fallecido',
    lessonsInfo: '10 Lecciones • 3 Quizzes',
    author: 'Freezer de Dragonbol',
    progress: 0.65,
    color: const Color(0xFF5B3BAD), // Rojo de Angular
  );

  final List<Course> availableCourses = [
    Course(
      title: 'Angular de Cero a Heroe',
      chapter: '',
      lessonsInfo: '25 Lecciones • 8 Quizzes',
      author: 'Bob Patiño',
      progress: 0,
      color: const Color(0xFF0277BD), // Azul de Flutter
    ),
    Course(
      title: 'Tutorial de como dormir',
      chapter: '',
      lessonsInfo: '18 Lecciones • 5 Quizzes',
      author: 'Lionel Messi',
      progress: 0,
      color: const Color(0xFF00D8FF), // Azul de React
    ),
  ];

  final List<String> studyGroupAvatars = [ 'A', 'B', 'C', 'D', 'E', 'F'];
  // --- FIN DE DATOS PILOTO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Continuar aprendizaje'),
            const SizedBox(height: 16),
            ContinueLearningCard(course: mainCourse),
            const SizedBox(height: 32),
            _buildSectionTitle('Cursos disponibles'),
            const SizedBox(height: 16),
            Row(
              children: [
                CourseCard(course: availableCourses[0]),
                const SizedBox(width: 16),
                CourseCard(course: availableCourses[1]),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Grupos de estudio', showAction: true),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: studyGroupAvatars.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Text(
                        studyGroupAvatars[index],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF131F24),
      elevation: 0,
      leadingWidth: 80,
      leading: const Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white24,
          child: Text('EN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, Nine',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            'Miércoles, 24 de Sept.',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
          onPressed: () {},
        ),
        const SizedBox(width: 12),
      ],
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
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF2D3D41),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          label: 'Cursos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}
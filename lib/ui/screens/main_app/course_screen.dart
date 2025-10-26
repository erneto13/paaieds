import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/widgets/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/custom_bottom_bar.dart';

class CoursesScreen extends StatelessWidget {
  final Function(int) onNavBarTap;
  final int currentIndex;

  const CoursesScreen({
    super.key,
    required this.onNavBarTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Mis Cursos", onProfileTap: () {}),
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 100,
                color: AppColors.lightBlue.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'Cursos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Próximamente podrás ver tus cursos aquí',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavBarTap,
      ),
    );
  }
}

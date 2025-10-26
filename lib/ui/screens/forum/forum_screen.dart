import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/widgets/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/custom_bottom_bar.dart';

class ForumScreen extends StatelessWidget {
  final Function(int) onNavBarTap;
  final int currentIndex;

  const ForumScreen({
    super.key,
    required this.onNavBarTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Foro", onProfileTap: () {}),
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 100,
                color: AppColors.lightBlue.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'Foro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Próximamente podrás ver el foro de discusión aquí.',
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

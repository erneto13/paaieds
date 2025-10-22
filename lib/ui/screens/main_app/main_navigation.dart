import 'package:flutter/material.dart';
import 'package:paaieds/core/models/user.dart';
import 'package:paaieds/ui/screens/forum/forum_screen.dart';
import 'package:paaieds/ui/screens/home/learn_test.dart';
import 'package:paaieds/ui/screens/main_app/course_screen.dart';
import 'package:paaieds/ui/screens/settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final UserModel user;

  const MainNavigation({super.key, required this.user});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      LearnTestScreen(
        user: widget.user,
        onNavBarTap: _onNavBarTap,
        currentIndex: _selectedIndex,
      ),
      CoursesScreen(
        user: widget.user,
        onNavBarTap: _onNavBarTap,
        currentIndex: _selectedIndex,
      ),
      ForumScreen(
        user: widget.user,
        onNavBarTap: _onNavBarTap,
        currentIndex: _selectedIndex,
      ),
      SettingsScreen(
        user: widget.user,
        onNavBarTap: _onNavBarTap,
        currentIndex: _selectedIndex,
      ),
    ];

    return screens[_selectedIndex];
  }
}

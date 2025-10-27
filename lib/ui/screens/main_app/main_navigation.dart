import 'package:flutter/material.dart';
import 'package:paaieds/ui/screens/forum/forum_screen.dart';
import 'package:paaieds/ui/screens/home/learn_test.dart';
import 'package:paaieds/ui/screens/main_app/roadmap/roadmap_list_screen.dart';
import 'package:paaieds/ui/screens/settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

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
      LearnTestScreen(onNavBarTap: _onNavBarTap, currentIndex: _selectedIndex),
      RoadmapsListScreen(
        onNavBarTap: _onNavBarTap,
        currentIndex: _selectedIndex,
      ),
      ForumScreen(onNavBarTap: _onNavBarTap, currentIndex: _selectedIndex),
      SettingsScreen(onNavBarTap: _onNavBarTap, currentIndex: _selectedIndex),
    ];

    return screens[_selectedIndex];
  }
}

import 'package:flutter/material.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/util/empty_state.dart';

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
      // ignore: avoid_print
      appBar: CustomAppBar(title: "Foro", onCustomIconTap: () => print('test')),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmptyState(
                icon: Icons.forum_outlined,
                title: 'Aún no hay mensajes',
                message: 'Participa en la conversación y comparte tus ideas.',
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

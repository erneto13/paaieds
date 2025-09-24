import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        fixedSize: const Size(50, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
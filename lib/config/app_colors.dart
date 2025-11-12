import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundWhite = Color(0xFFF4F7FF);
  static const Color backgroundButtom = Color(0xFF0264ff);
  
  static const Color lightBlue = Color(0xFF9EC9F2);
  static const Color skyBlue = Color(0xFF7BB6F0);
  static const Color oceanBlue = Color(0xFF5A9BEF);
  static const Color deepBlue = Color(0xFF1E6CD6);

  static const Color primaryLight = oceanBlue;
  static const Color primary = deepBlue;
  static const Color accent = skyBlue;
  static const Color highlight = lightBlue;

  static final Color backgroundLight = oceanBlue.withValues(alpha: 0.1);
  static const Color surface = Colors.white;

  static final Color textPrimary = Colors.grey[800]!;
  static final Color textSecondary = Colors.grey[600]!;
  static final Color textLight = Colors.grey[400]!;
}
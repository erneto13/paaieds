import 'package:flutter/material.dart';
// Asegúrate de importar tu nueva pantalla de bienvenida
import 'package:paaieds/ui/screens/auth/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TWORD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: Typography().white.apply(fontFamily: 'DinNextRounded'),
        scaffoldBackgroundColor: const Color(0xFF131F24),
      ),
      home: const WelcomeScreen(),
    );
  }
}
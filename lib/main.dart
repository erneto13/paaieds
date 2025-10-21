import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paaieds/ui/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paaieds/firebase_options.dart';

void main() async {
  await dotenv.load(fileName: "../.env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: const LoginScreen(),
    );
  }
}

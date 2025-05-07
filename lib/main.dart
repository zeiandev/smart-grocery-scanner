import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Grocery Scanner',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9FDF9),
        primaryColor: Colors.green,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start here
    );
  }
}

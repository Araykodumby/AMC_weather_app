import 'package:flutter/material.dart';
import 'package:wheather_app/screens/splash_screen.dart';
import 'package:wheather_app/screens/modern_weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      // Start with splash screen
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/weather': (context) => const ModernWeatherScreen(),
      },
    );
  }
}
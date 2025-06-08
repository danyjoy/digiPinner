import 'package:digipin/ui/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiPinner',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'OpenSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'OpenSans'),
          bodyLarge: TextStyle(fontFamily: 'OpenSans'),
          titleMedium: TextStyle(fontFamily: 'OpenSans'),
          titleLarge: TextStyle(fontFamily: 'OpenSans'),
          headlineMedium: TextStyle(fontFamily: 'OpenSans'),
          headlineLarge: TextStyle(fontFamily: 'OpenSans'),
        ),
      ),
      home: const MyHomePage(title: 'DigiPinner'),
    );
  }
}

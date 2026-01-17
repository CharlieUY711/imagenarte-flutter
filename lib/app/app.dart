import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_theme.dart';
import 'package:imagenarte/presentation/screens/home_screen.dart';

class ImagenArteApp extends StatelessWidget {
  const ImagenArteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/snig/snig_handler.dart';
import 'screens/snig/snig_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SnigHandler()..cargarDatosEjemplo()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNIG Connect',
      theme: AppTheme.lightTheme,
      home: const SnigScreen(),
      
    );
  }
}

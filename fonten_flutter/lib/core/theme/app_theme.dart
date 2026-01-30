import 'package:flutter/material.dart';

class AppTheme {
  // Colores del diseño original (SNIG Connect)
  static const Color primary = Color(0xFF1e6c41);
  static const Color secondary = Color.fromARGB(255, 108, 103, 30);
  static const Color primaryDark = Color(0xFF165a35);
  static const Color background = Color(0xFFf2f4f3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color okBg = Color(0xFFdcfce7);
  static const Color okText = Color(0xFF166534);
  static const Color errorBg = Color(0xFFfee2e2);
  static const Color errorText = Color(0xFF991b1b);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        surface: surface,
        error: errorText,
      ),
      // Estilo de las tarjetas (Bordes redondeados y sombra suave)
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surface,
      ),
      // Tema para AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      // Botón flotante
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

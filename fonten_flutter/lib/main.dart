// fonten_flutter/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/config_drawer/config_drawer_handler.dart';
import 'package:provider/provider.dart';
import 'screens/snig/snig_handler.dart';
import 'screens/snig/snig_screen.dart';
import 'core/theme/app_theme.dart';

/// Punto de entrada principal de la aplicación.
void main() {
  // runApp lanza el widget raíz que se dibujará en la pantalla del dispositivo.
  runApp(
    /// MultiProvider permite inyectar múltiples clases de estado (servicios)
    /// en la parte superior del árbol de widgets.
    MultiProvider(
      providers: [
        /// ChangeNotifierProvider crea una instancia única de SnigHandler.
        /// Al heredar de ChangeNotifier, cualquier llamada a notifyListeners()
        /// dentro de SnigHandler reconstruirá automáticamente los widgets que dependan de él.
        ChangeNotifierProvider(create: (_) => SnigHandler()),

        ChangeNotifierProvider(create: (_) => ConfigDrawerHandler()),
      ],

      /// MyApp es el hijo que contendrá toda la estructura visual de la aplicación.
      child: const MyApp(),
    ),
  );
}

/// Widget de configuración global de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura elementos esenciales como el sistema de navegación,
    // temas visuales y localización.
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Quita la etiqueta de "Debug" en la esquina.
      title: 'SNIG Connect', // Nombre de la app en el sistema operativo.

      // Aplica una configuración de colores y estilos definida en una clase externa.
      theme: AppTheme.lightTheme,

      // SnigScreen es la pantalla principal que se mostrará al iniciar.
      home: const SnigScreen(),
    );
  } //fin build
}

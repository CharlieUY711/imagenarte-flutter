import 'package:flutter/material.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/wizard/wizard_screen.dart';
import '../ui/screens/export/export_screen.dart';
import '../presentation/screens/editor_screen.dart';
import '../presentation/screens/editor_screen_visual.dart';
import '../utils/debug_gate.dart';
import 'package:core/domain/roi.dart';
import 'package:core/domain/operation.dart';
import 'package:core/application/editor_controller.dart';
// Import de pantalla debug: solo se instancia en modo debug
import '../ui/screens/debug/ux_testing_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String wizard = '/wizard';
  static const String export = '/export';
  static const String editor = '/editor';
  static const String uxTesting = '/debug/ux-testing';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case wizard:
        return MaterialPageRoute(builder: (_) => const WizardScreen());
      case export:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExportScreen(
            imagePath: args?['imagePath'] as String?,
            operations: (args?['operations'] as List?)?.cast<Operation>() ?? const [],
            rois: args?['rois'] as List<ROI>?,
            effectMode: args?['effectMode'] as EffectMode?,
            effectIntensity: args?['effectIntensity'] as int?,
          ),
        );
      case editor:
        // Usar versión visual simplificada para corregir UI primero
        // TODO: Cambiar a EditorScreen cuando se integren funcionalidades
        return MaterialPageRoute(
          builder: (_) => const EditorScreenVisual(),
        );
      // GATING ESTRICTO: Rutas debug solo se registran en modo debug
      // En release, estas rutas no existen y caen en el default (NotFound)
      case uxTesting:
        if (DebugGate.isDebugModeEnabled()) {
          return MaterialPageRoute(builder: (_) => const UXTestingScreen());
        }
        // En release, cae al default (NotFound)
        break;
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
    // Fallback: si es ruta debug en release, cae aquí
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Ruta no encontrada')),
      ),
    );
  }
}

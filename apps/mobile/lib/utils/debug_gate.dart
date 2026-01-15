import 'package:flutter/foundation.dart';

/// Utilidad para gating estricto de funcionalidades debug
/// 
/// Garantiza que NADA relacionado con debug sea accesible en builds release.
/// Cumple con D0 estricto: cero contaminación de código debug en release.
class DebugGate {
  /// Verifica si el build actual permite funcionalidades debug
  /// 
  /// Retorna `true` SOLO en modo debug (kDebugMode).
  /// En release siempre retorna `false`, incluso si se intenta forzar.
  static bool isDebugModeEnabled() {
    return kDebugMode;
  }

  /// Verifica si una ruta es de debug
  /// 
  /// Retorna `true` si la ruta comienza con `/debug/`
  static bool isDebugRoute(String? route) {
    if (route == null) return false;
    return route.startsWith('/debug/');
  }

  /// Valida si se puede acceder a una ruta debug
  /// 
  /// Retorna `true` SOLO si:
  /// - La ruta es de debug Y
  /// - El build está en modo debug
  /// 
  /// En release, siempre retorna `false` para rutas debug.
  static bool canAccessDebugRoute(String? route) {
    if (!isDebugRoute(route)) {
      // Rutas no-debug siempre son accesibles
      return true;
    }
    // Rutas debug solo accesibles en modo debug
    return isDebugModeEnabled();
  }

  /// Obtiene un mensaje de error para acceso denegado a rutas debug
  static String getAccessDeniedMessage() {
    return 'Acceso denegado: Esta funcionalidad solo está disponible en builds de debug.';
  }
}

/// Feature flags para controlar funcionalidades de la aplicación
/// 
/// Estos flags permiten habilitar/deshabilitar features sin modificar
/// múltiples archivos en el código.
class FeatureFlags {
  /// Flag para habilitar el Wizard v0.10
  /// 
  /// Cuando está en `false`, el Wizard queda bloqueado y no es accesible
  /// desde la UI ni por rutas directas. El código permanece intacto.
  /// 
  /// Para habilitar el Wizard internamente, cambiar a `true`.
  static const bool kEnableWizardV010 = false;
}

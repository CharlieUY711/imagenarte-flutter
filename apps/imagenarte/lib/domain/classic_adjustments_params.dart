/// Parámetros para ajustes clásicos de imagen
/// 
/// Brillo, Contraste, Saturación: rango -100..+100 (default 0)
/// Nitidez: rango 0..100 (default 0)
class ClassicAdjustmentsParams {
  final double brightness;   // -100..+100, default 0
  final double contrast;      // -100..+100, default 0
  final double saturation;    // -100..+100, default 0
  final double sharpness;     // 0..100, default 0

  const ClassicAdjustmentsParams({
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.sharpness = 0.0,
  });

  /// Crea una copia con algunos valores modificados
  ClassicAdjustmentsParams copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
  }) {
    return ClassicAdjustmentsParams(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      sharpness: sharpness ?? this.sharpness,
    );
  }

  /// Resetea todos los valores a defaults
  ClassicAdjustmentsParams reset() {
    return const ClassicAdjustmentsParams();
  }

  /// Verifica si todos los valores están en default (sin ajustes aplicados)
  bool get isDefault {
    return brightness == 0.0 &&
        contrast == 0.0 &&
        saturation == 0.0 &&
        sharpness == 0.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassicAdjustmentsParams &&
        other.brightness == brightness &&
        other.contrast == contrast &&
        other.saturation == saturation &&
        other.sharpness == sharpness;
  }

  @override
  int get hashCode {
    return Object.hash(brightness, contrast, saturation, sharpness);
  }
}

/// Constantes para rangos de ajustes
class ClassicAdjustmentsRanges {
  static const double minBrightness = -100.0;
  static const double maxBrightness = 100.0;
  static const double defaultBrightness = 0.0;

  static const double minContrast = -100.0;
  static const double maxContrast = 100.0;
  static const double defaultContrast = 0.0;

  static const double minSaturation = -100.0;
  static const double maxSaturation = 100.0;
  static const double defaultSaturation = 0.0;

  static const double minSharpness = 0.0;
  static const double maxSharpness = 100.0;
  static const double defaultSharpness = 0.0;
}

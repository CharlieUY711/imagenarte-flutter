/// Tipo de ROI (Región de Interés)
enum RoiType {
  /// Detección automática de rostro
  faceAuto,
  /// Selección manual del usuario
  manual,
}

/// Forma de la ROI
enum RoiShape {
  /// Rectángulo
  rect,
  /// Elipse
  ellipse,
}

/// Representa una Región de Interés (ROI) normalizada
/// 
/// Todas las coordenadas están normalizadas entre 0.0 y 1.0,
/// independientemente de la resolución de la imagen.
class ROI {
  /// Identificador único de la ROI
  final String id;
  
  /// Tipo de ROI (auto o manual)
  final RoiType type;
  
  /// Forma de la ROI
  final RoiShape shape;
  
  /// Coordenada X normalizada (0.0 = borde izquierdo, 1.0 = borde derecho)
  final double x;
  
  /// Coordenada Y normalizada (0.0 = borde superior, 1.0 = borde inferior)
  final double y;
  
  /// Ancho normalizado (0.0 = sin ancho, 1.0 = ancho completo)
  final double width;
  
  /// Alto normalizado (0.0 = sin alto, 1.0 = alto completo)
  final double height;
  
  /// Si está bloqueada (no se puede modificar/eliminar automáticamente)
  final bool locked;
  
  /// Nivel de confianza (solo para detección automática)
  /// Rango: 0.0 a 1.0
  final double? confidence;

  ROI({
    required this.id,
    required this.type,
    this.shape = RoiShape.rect,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.locked = false,
    this.confidence,
  }) : assert(x >= 0.0 && x <= 1.0, 'x debe estar entre 0.0 y 1.0'),
       assert(y >= 0.0 && y <= 1.0, 'y debe estar entre 0.0 y 1.0'),
       assert(width > 0.0 && width <= 1.0, 'width debe estar entre 0.0 y 1.0'),
       assert(height > 0.0 && height <= 1.0, 'height debe estar entre 0.0 y 1.0'),
       assert(x + width <= 1.0, 'x + width no puede exceder 1.0'),
       assert(y + height <= 1.0, 'y + height no puede exceder 1.0'),
       assert(confidence == null || (confidence >= 0.0 && confidence <= 1.0),
              'confidence debe estar entre 0.0 y 1.0');

  /// Crea una copia de esta ROI con valores modificados
  ROI copyWith({
    String? id,
    RoiType? type,
    RoiShape? shape,
    double? x,
    double? y,
    double? width,
    double? height,
    bool? locked,
    double? confidence,
  }) {
    return ROI(
      id: id ?? this.id,
      type: type ?? this.type,
      shape: shape ?? this.shape,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      locked: locked ?? this.locked,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Convierte coordenadas normalizadas a píxeles absolutos
  RectAbsolute toAbsolute(int imageWidth, int imageHeight) {
    return RectAbsolute(
      x: (x * imageWidth).round(),
      y: (y * imageHeight).round(),
      width: (width * imageWidth).round(),
      height: (height * imageHeight).round(),
    );
  }

  /// Calcula el área de la ROI (normalizada)
  double get area => width * height;

  /// Calcula el centro de la ROI (normalizado)
  PointNormalized get center => PointNormalized(
    x: x + width / 2,
    y: y + height / 2,
  );
}

/// Rectángulo en coordenadas absolutas (píxeles)
class RectAbsolute {
  final int x;
  final int y;
  final int width;
  final int height;

  RectAbsolute({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Convierte a coordenadas normalizadas
  ROI toNormalized(String id, RoiType type, {RoiShape shape = RoiShape.rect}) {
    // Nota: Necesitamos las dimensiones de la imagen para normalizar
    // Este método asume que se llamará desde un contexto donde se conoce la imagen
    throw UnimplementedError('Usar ROI.fromAbsolute en su lugar');
  }
}

/// Punto normalizado (0.0 a 1.0)
class PointNormalized {
  final double x;
  final double y;

  PointNormalized({
    required this.x,
    required this.y,
  }) : assert(x >= 0.0 && x <= 1.0),
       assert(y >= 0.0 && y <= 1.0);
}

/// Crea una ROI desde coordenadas absolutas
ROI roiFromAbsolute({
  required String id,
  required RoiType type,
  required int x,
  required int y,
  required int width,
  required int height,
  required int imageWidth,
  required int imageHeight,
  RoiShape shape = RoiShape.rect,
  bool locked = false,
  double? confidence,
}) {
  return ROI(
    id: id,
    type: type,
    shape: shape,
    x: x / imageWidth,
    y: y / imageHeight,
    width: width / imageWidth,
    height: height / imageHeight,
    locked: locked,
    confidence: confidence,
  );
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';

/// Clase auxiliar para retornar el path procesado de selección libre
class _ProcessedFreehandPath {
  final Path pathCanvas;
  final Path pathImage;
  final Rect boundsImage;
  
  _ProcessedFreehandPath({
    required this.pathCanvas,
    required this.pathImage,
    required this.boundsImage,
  });
}

enum EditorTool {
  none,
  home,
  geometricSelection,
  freeSelection,
  scissors,
  color,
  classicAdjustments,
  undo,
  save,
  // Herramientas movidas a Action List
  blur,
  pixelate,
  watermark,
  metadata,
}

enum CropPreset {
  p9_16, // 9:16
  p1_1, // 1:1
  p16_9, // 16:9
  p4_3, // 4:3
  circular, // Circular
}

enum ColorMode {
  color,
  grayscale,
  sepia,
  blackAndWhite,
}

enum ClassicAdjustment {
  brightness,
  contrast,
  saturation,
  sharpness,
}

/// Target de transformación activo
/// Define qué objeto está siendo transformado actualmente
enum TransformTarget {
  none,
  selection, // ROI/Selección
  watermarkText, // Marca de agua de texto
  watermarkLogo, // Marca de agua de logo
}

enum SelectionMode {
  geometric,
  freehand,
}

/// Contexto activo único del editor
/// Define qué overlay debe mostrarse (SOLO UNO a la vez)
enum EditorContext {
  none,
  selectionRatios,
  freeSelection,
  scissors,
  colorPresets,
  classicAdjustments,
  action_blur,
  action_pixelate,
  action_watermark,
  action_metadata,
}

/// Modo de la barra blanca
enum WhiteBarMode {
  structured, // Muestra info estructurada (Selección/versión) con márgenes 16-16
  support, // Muestra mensajes de soporte usando ancho interior entre iconos
}

  /// Snapshot del estado del editor para undo
class EditorSnapshot {
  final EditorTool activeTool;
  final CropPreset? cropPreset;
  final TransformTarget activeTransformTarget;
  final TransformableGeometry? selectionGeometry;
  final TransformableGeometry? watermarkGeometry;

  EditorSnapshot({
    required this.activeTool,
    required this.cropPreset,
    required this.activeTransformTarget,
    required this.selectionGeometry,
    required this.watermarkGeometry,
  });
}

class EditorUiState extends ChangeNotifier {
  EditorTool _activeTool = EditorTool.none;
  CropPreset? _cropPreset;
  TransformTarget _activeTransformTarget = TransformTarget.none;
  
  // Contexto activo único (SINGLE SOURCE OF TRUTH)
  EditorContext _activeContext = EditorContext.none;
  
  // Action List: acción activa en modo foco (nullable)
  // Si es null → Estado A (reposo): lista completa
  // Si no es null → Estado B (foco): solo esta acción visible
  EditorTool? _activeAction;
  
  // Geometría de selección (ROI)
  TransformableGeometry? _selectionGeometry;
  
  // Modo de selección
  SelectionMode _selectionMode = SelectionMode.geometric;
  
  // Path para selección libre (mano alzada)
  Path? _freeSelectionPath;
  
  // Puntos en tiempo real durante el dibujo (coordenadas canvas)
  List<Offset> _freehandPointsCanvas = [];
  
  // Path final en coordenadas canvas (después de simplificación y suavizado)
  Path? _freehandPathCanvas;
  
  // Path final en coordenadas de imagen (pixels)
  Path? _freehandPathImage;
  
  // Bounding box del path en coordenadas de imagen (para métricas)
  Rect? _freehandBoundsImagePx;
  
  // Estado de dibujo activo
  bool _isDrawingFreehand = false;
  
  // Geometría de watermark (stub por ahora)
  TransformableGeometry? _watermarkGeometry;
  bool _watermarkVisible = true;
  bool _watermarkIsText = true; // true = texto, false = logo

  // Color mode
  ColorMode _colorMode = ColorMode.color;
  
  // Classic adjustments (0-100, donde 50 es neutro)
  ClassicAdjustment? _activeClassicAdjustment;
  double _brightness = 50.0; // 0-100
  double _contrast = 50.0; // 0-100
  double _saturation = 50.0; // 0-100
  double _sharpness = 50.0; // 0-100
  
  // Intensidades de efectos (0-100)
  double _blurIntensity = 50.0; // 0-100
  double _pixelateIntensity = 50.0; // 0-100
  double _watermarkOpacity = 100.0; // 0-100

  // Estado de inversión de selección para tijera
  bool _selectionInverted = false; // false = interior, true = exterior

  // Nombre de versión de selección (editable)
  String? _selectionVersionBaseName;
  String? _originalFileExtension; // Extensión del archivo original (fija)

  // Mensaje de estado para la barra blanca
  String? _statusMessage;

  // Barra blanca: modo y textos
  WhiteBarMode _whiteBarMode = WhiteBarMode.support;
  String? _structuredInfoText; // Ej: "Selección: ... · 185×329 px · ~0.10 MB"
  String? _supportMessageText; // Ej: "Selecciona una herramienta para comenzar"

  // Métricas aproximadas (TRACK B)
  int _approxWidthPx = 0;
  int _approxHeightPx = 0;
  int _approxBytes = 0;
  String? _approxLabelLeft; // Ej: "Selección: ..." o "Color: Sepia"
  Size? _canvasSize; // Tamaño del canvas para mapeo
  
  // Timer para throttle de selección
  Timer? _selectionThrottleTimer;
  static const Duration _selectionThrottleDelay = Duration(milliseconds: 50);

  // Undo stack con capacidad de 10
  final List<EditorSnapshot> _undoStack = [];
  static const int _maxUndoLevels = 10;

  EditorTool get activeTool => _activeTool;
  EditorContext get activeContext => _activeContext;
  EditorTool? get activeAction => _activeAction;
  CropPreset? get cropPreset => _cropPreset;
  TransformTarget get activeTransformTarget => _activeTransformTarget;
  TransformableGeometry? get selectionGeometry => _selectionGeometry;
  Path? get freeSelectionPath => _freeSelectionPath;
  SelectionMode get selectionMode => _selectionMode;
  List<Offset> get freehandPointsCanvas => List.unmodifiable(_freehandPointsCanvas);
  Path? get freehandPathCanvas => _freehandPathCanvas;
  Path? get freehandPathImage => _freehandPathImage;
  Rect? get freehandBoundsImagePx => _freehandBoundsImagePx;
  bool get isDrawingFreehand => _isDrawingFreehand;
  TransformableGeometry? get watermarkGeometry => _watermarkGeometry;
  bool get watermarkVisible => _watermarkVisible;
  bool get watermarkIsText => _watermarkIsText;
  ColorMode get colorMode => _colorMode;
  ClassicAdjustment? get activeClassicAdjustment => _activeClassicAdjustment;
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get sharpness => _sharpness;
  double get blurIntensity => _blurIntensity;
  double get pixelateIntensity => _pixelateIntensity;
  double get watermarkOpacity => _watermarkOpacity;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get hasValidSelection => _selectionGeometry != null || 
      _freeSelectionPath != null || 
      _freehandPathCanvas != null;
  bool get selectionInverted => _selectionInverted;
  String? get selectionVersionBaseName => _selectionVersionBaseName;
  String? get originalFileExtension => _originalFileExtension;
  String? get selectionVersionFullName {
    if (_selectionVersionBaseName == null || _originalFileExtension == null) {
      return null;
    }
    return '$_selectionVersionBaseName$_originalFileExtension';
  }
  String? get statusMessage => _statusMessage;
  WhiteBarMode get whiteBarMode => _whiteBarMode;
  String? get structuredInfoText => _structuredInfoText;
  String? get supportMessageText => _supportMessageText;
  
  // Getters para métricas aproximadas
  int get approxWidthPx => _approxWidthPx;
  int get approxHeightPx => _approxHeightPx;
  int get approxBytes => _approxBytes;
  String? get approxLabelLeft => _approxLabelLeft;
  Size? get canvasSize => _canvasSize;

  /// Establece el contexto activo único
  /// REEMPLAZA cualquier contexto anterior (limpia overlays previos)
  void setContext(EditorContext ctx) {
    debugPrint("setContext: $ctx  stateHash=${identityHashCode(this)}");
    _activeContext = ctx;
    
    // Limpiar estados incompatibles
    if (ctx == EditorContext.none) {
      _activeAction = null;
    } else if (ctx == EditorContext.action_blur ||
               ctx == EditorContext.action_pixelate ||
               ctx == EditorContext.action_watermark ||
               ctx == EditorContext.action_metadata) {
      // Si se entra por action list, mantener activeAction
      // (se establece en toggleTool)
    } else {
      // Si se entra por toolbar, limpiar activeAction
      _activeAction = null;
    }
    
    notifyListeners();
  }

  /// Limpia el contexto activo (cierra overlay)
  void clearActiveAction() {
    _activeAction = null;
    notifyListeners();
  }

  void setActiveTool(EditorTool tool) {
    // Undo y Save no cambian el tool activo, solo ejecutan acciones
    if (tool == EditorTool.undo) {
      undo();
      return;
    }
    if (tool == EditorTool.save) {
      requestSave();
      // Salida de foco: limpiar activeAction y contexto
      _activeAction = null;
      setContext(EditorContext.none);
      return;
    }
    
    // Home limpia activeAction y contexto (salida de foco)
    if (tool == EditorTool.home) {
      _activeAction = null;
      setContext(EditorContext.none);
      _activeTool = tool;
      notifyListeners();
      return;
    }
    
    _activeTool = tool;
    
    // Mapear tool a contexto y establecerlo (esto reemplaza cualquier contexto anterior)
    switch (tool) {
      case EditorTool.geometricSelection:
        setContext(EditorContext.selectionRatios);
        break;
      case EditorTool.freeSelection:
        setContext(EditorContext.freeSelection);
        break;
      case EditorTool.scissors:
        // La tijera muestra overlay para elegir Interior/Exterior
        setContext(EditorContext.scissors);
        break;
      case EditorTool.color:
        setContext(EditorContext.colorPresets);
        break;
      case EditorTool.classicAdjustments:
        setContext(EditorContext.classicAdjustments);
        break;
      case EditorTool.blur:
        setContext(EditorContext.action_blur);
        break;
      case EditorTool.pixelate:
        setContext(EditorContext.action_pixelate);
        break;
      case EditorTool.watermark:
        setContext(EditorContext.action_watermark);
        break;
      case EditorTool.metadata:
        setContext(EditorContext.action_metadata);
        break;
      default:
        setContext(EditorContext.none);
        break;
    }
    
    // Lógica para selección geométrica
    if (tool == EditorTool.geometricSelection) {
      _cropPreset ??= CropPreset.p1_1; // Default temporal (se calculará automáticamente cuando se conozca el tamaño de la imagen)
      _activeTransformTarget = TransformTarget.selection;
    } else if (tool == EditorTool.freeSelection) {
      // Selección libre: limpiar path anterior si existe
      _freeSelectionPath = null;
      _freehandPathCanvas = null;
      _freehandPathImage = null;
      _freehandPointsCanvas.clear();
      _freehandBoundsImagePx = null;
      _selectionMode = SelectionMode.freehand;
      _activeTransformTarget = TransformTarget.none;
    } else if (tool == EditorTool.color || tool == EditorTool.classicAdjustments) {
      // Color y ajustes no usan transform target
      _activeTransformTarget = TransformTarget.none;
    } else if (tool == EditorTool.watermark) {
      if (_watermarkGeometry != null) {
        _activeTransformTarget = _watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo;
      } else {
        _activeTransformTarget = TransformTarget.none;
      }
    } else if (tool == EditorTool.blur || tool == EditorTool.pixelate) {
      // Para herramientas que usan selección ROI
      _activeTransformTarget = TransformTarget.selection;
    } else {
      _activeTransformTarget = TransformTarget.none;
    }
  }

  void toggleTool(EditorTool tool) {
    // Verificar si es una acción de la Action List
    final isActionListTool = tool == EditorTool.blur ||
        tool == EditorTool.pixelate ||
        tool == EditorTool.watermark ||
        tool == EditorTool.metadata;
    
    if (isActionListTool) {
      // Si se toca la misma acción, salir de foco
      if (_activeAction == tool) {
        _activeAction = null;
        _activeTool = EditorTool.none;
        setContext(EditorContext.none);
      } else {
        // Cambiar foco a la nueva acción
        _activeAction = tool;
        setActiveTool(tool);
      }
      return;
    }
    
    // Para otras herramientas, comportamiento normal
    if (_activeTool == tool) {
      // Si se toca el mismo tool, resetearlo y cerrar contexto
      _resetTool(tool);
      setContext(EditorContext.none);
    } else {
      // Activar el nuevo tool (esto establece el contexto)
      setActiveTool(tool);
    }
  }

  void _resetTool(EditorTool tool) {
    switch (tool) {
      case EditorTool.geometricSelection:
        // Resetear cropPreset al valor default
        _cropPreset = CropPreset.p1_1;
        _selectionGeometry = null;
        break;
      case EditorTool.freeSelection:
        _freeSelectionPath = null;
        _freehandPathCanvas = null;
        _freehandPathImage = null;
        _freehandPointsCanvas.clear();
        _freehandBoundsImagePx = null;
        _selectionMode = SelectionMode.geometric;
        break;
      case EditorTool.color:
        _colorMode = ColorMode.color;
        break;
      case EditorTool.classicAdjustments:
        _brightness = 0.0;
        _contrast = 0.0;
        _saturation = 0.0;
        _sharpness = 0.0;
        break;
      default:
        // Otros tools no tienen estado que resetear
        break;
    }
    notifyListeners();
  }

  void setCropPreset(CropPreset preset) {
    _cropPreset = preset;
    notifyListeners();
  }

  void setActiveTransformTarget(TransformTarget target) {
    _activeTransformTarget = target;
    notifyListeners();
  }

  void setWatermarkGeometry(TransformableGeometry? geometry) {
    _watermarkGeometry = geometry;
    if (geometry != null && _activeTool == EditorTool.watermark) {
      _activeTransformTarget = _watermarkIsText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
    }
    notifyListeners();
  }

  void updateWatermarkGeometry(TransformableGeometry geometry) {
    _watermarkGeometry = geometry;
    notifyListeners();
  }

  /// Calcula la proporción más cercana a la imagen original
  CropPreset calculateClosestPreset(double imageWidth, double imageHeight) {
    if (imageWidth <= 0 || imageHeight <= 0) return CropPreset.p1_1;
    
    final imageRatio = imageWidth / imageHeight;
    
    final ratios = {
      CropPreset.p9_16: 9.0 / 16.0,
      CropPreset.p1_1: 1.0,
      CropPreset.p16_9: 16.0 / 9.0,
      CropPreset.p4_3: 4.0 / 3.0,
    };
    
    CropPreset closest = CropPreset.p1_1;
    double minDiff = double.infinity;
    
    for (final entry in ratios.entries) {
      final diff = (imageRatio - entry.value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = entry.key;
      }
    }
    
    return closest;
  }

  /// Inicializa selección geométrica con proporción automática
  void initializeGeometricSelection(Size canvasSize, Size? imageSize) {
    if (_activeTool != EditorTool.geometricSelection) return;
    
    // Calcular proporción más cercana
    if (imageSize != null) {
      _cropPreset = calculateClosestPreset(imageSize.width, imageSize.height);
    } else {
      _cropPreset = calculateClosestPreset(canvasSize.width, canvasSize.height);
    }
    
    // Crear selección centrada con la proporción calculada
    final center = Offset(canvasSize.width * 0.5, canvasSize.height * 0.5);
    final maxSize = math.min(canvasSize.width, canvasSize.height) * 0.8;
    
    double width, height;
    if (_cropPreset == CropPreset.circular) {
      width = height = maxSize;
      _selectionGeometry = TransformableGeometry(
        shape: TransformableShape.circle,
        center: center,
        size: Size(width, height),
        rotation: 0.0,
      );
    } else {
      double ratio;
      switch (_cropPreset!) {
        case CropPreset.p9_16:
          ratio = 9.0 / 16.0;
          break;
        case CropPreset.p1_1:
          ratio = 1.0;
          break;
        case CropPreset.p16_9:
          ratio = 16.0 / 9.0;
          break;
        case CropPreset.p4_3:
          ratio = 4.0 / 3.0;
          break;
        case CropPreset.circular:
          ratio = 1.0; // No debería llegar aquí
          break;
      }
      
      if (ratio < 1.0) {
        // Vertical
        height = maxSize;
        width = height * ratio;
      } else {
        // Horizontal
        width = maxSize;
        height = width / ratio;
      }
      
      _selectionGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: center,
        size: Size(width, height),
        rotation: 0.0,
      );
    }
    
    _activeTransformTarget = TransformTarget.selection;
    notifyListeners();
  }

  void initializeSelectionIfNeeded(Size canvasSize) {
    if (_selectionGeometry == null && 
        (_activeTool == EditorTool.blur || 
         _activeTool == EditorTool.pixelate)) {
      // Crear círculo por defecto centrado en el canvas
      final radius = math.min(canvasSize.width, canvasSize.height) * 0.2;
      _selectionGeometry = TransformableGeometry(
        shape: TransformableShape.circle,
        center: Offset(canvasSize.width * 0.5, canvasSize.height * 0.5),
        size: Size(radius * 2, radius * 2),
        rotation: 0.0,
      );
      _activeTransformTarget = TransformTarget.selection;
      notifyListeners();
    }
  }

  void updateSelectionGeometry(TransformableGeometry geometry) {
    _selectionGeometry = geometry;
    notifyListeners();
    // El recálculo de métricas se dispara desde la UI cuando detecta el cambio
  }

  void setFreeSelectionPath(Path? path) {
    _freeSelectionPath = path;
    notifyListeners();
  }

  /// Inicia el dibujo de selección libre
  void startFreehand() {
    _isDrawingFreehand = true;
    _freehandPointsCanvas.clear();
    notifyListeners();
  }

  /// Agrega un punto durante el dibujo (solo si está dentro del área de la imagen)
  void addFreehandPoint(Offset canvasPoint, Rect? imageDestRect) {
    if (!_isDrawingFreehand) return;
    
    // Solo agregar si está dentro del área de la imagen
    if (imageDestRect != null && !imageDestRect.contains(canvasPoint)) {
      return;
    }
    
    // Aplicar distance threshold (2-3 px) para no guardar demasiados puntos
    if (_freehandPointsCanvas.isNotEmpty) {
      final lastPoint = _freehandPointsCanvas.last;
      final distance = (canvasPoint - lastPoint).distance;
      if (distance < 2.5) {
        return; // Ignorar puntos muy cercanos
      }
    }
    
    _freehandPointsCanvas.add(canvasPoint);
    notifyListeners();
  }

  /// Finaliza el dibujo y procesa el path (simplificación, suavizado, cierre)
  void endFreehand({
    required Size? canvasSize,
    required Size? imageSize,
  }) {
    if (!_isDrawingFreehand || _freehandPointsCanvas.length < 3) {
      _isDrawingFreehand = false;
      _freehandPointsCanvas.clear();
      notifyListeners();
      return;
    }
    
    // Importar helper de simplificación y suavizado
    // (se implementará en un archivo separado)
    final processedPath = _processFreehandPath(
      points: _freehandPointsCanvas,
      canvasSize: canvasSize,
      imageSize: imageSize,
    );
    
    if (processedPath != null) {
      _freehandPathCanvas = processedPath.pathCanvas;
      _freehandPathImage = processedPath.pathImage;
      _freehandBoundsImagePx = processedPath.boundsImage;
      _freeSelectionPath = _freehandPathCanvas; // Compatibilidad con código existente
    }
    
    _isDrawingFreehand = false;
    _freehandPointsCanvas.clear();
    notifyListeners();
  }

  /// Limpia la selección libre
  void clearFreehand() {
    _freeSelectionPath = null;
    _freehandPathCanvas = null;
    _freehandPathImage = null;
    _freehandPointsCanvas.clear();
    _freehandBoundsImagePx = null;
    _isDrawingFreehand = false;
    _selectionMode = SelectionMode.geometric;
    notifyListeners();
  }

  /// Procesa el path: simplificación RDP, suavizado, cierre y conversión a coordenadas de imagen
  _ProcessedFreehandPath? _processFreehandPath({
    required List<Offset> points,
    required Size? canvasSize,
    required Size? imageSize,
  }) {
    if (points.length < 3 || canvasSize == null || imageSize == null) {
      return null;
    }
    
    // 1. Simplificar con RDP (tolerancia 2-3 px en canvas)
    final simplified = _rdpSimplify(points, tolerance: 2.5);
    
    if (simplified.length < 3) {
      return null;
    }
    
    // 2. Cerrar el path si es necesario
    final firstPoint = simplified.first;
    final lastPoint = simplified.last;
    final closeDistance = (lastPoint - firstPoint).distance;
    final shouldClose = closeDistance < 12.0; // Umbral de 12 px
    
    // 3. Convertir puntos a coordenadas de imagen ANTES de suavizar
    final imageDestRect = _calculateImageRectInCanvas(canvasSize, imageSize);
    final scaleX = imageSize.width / imageDestRect.width;
    final scaleY = imageSize.height / imageDestRect.height;
    
    final imagePoints = simplified.map((point) {
      return Offset(
        ((point.dx - imageDestRect.left) * scaleX).clamp(0.0, imageSize.width),
        ((point.dy - imageDestRect.top) * scaleY).clamp(0.0, imageSize.height),
      );
    }).toList();
    
    // 4. Suavizar en coordenadas canvas
    final smoothedPathCanvas = _smoothPath(simplified, shouldClose: shouldClose);
    
    // 5. Suavizar en coordenadas imagen
    final smoothedPathImage = _smoothPath(imagePoints, shouldClose: shouldClose);
    
    // 6. Calcular bounding box en coordenadas de imagen
    final boundsImage = _calculatePathBounds(smoothedPathImage);
    
    return _ProcessedFreehandPath(
      pathCanvas: smoothedPathCanvas,
      pathImage: smoothedPathImage,
      boundsImage: boundsImage,
    );
  }

  /// Simplificación Ramer-Douglas-Peucker
  List<Offset> _rdpSimplify(List<Offset> points, {required double tolerance}) {
    if (points.length <= 2) return points;
    
    // Encontrar el punto más lejano de la línea entre el primero y el último
    double maxDistance = 0.0;
    int maxIndex = 0;
    
    final first = points.first;
    final last = points.last;
    final lineVector = last - first;
    final lineLength = lineVector.distance;
    
    if (lineLength < tolerance) {
      // Si la línea es muy corta, retornar solo los extremos
      return [first, last];
    }
    
    for (int i = 1; i < points.length - 1; i++) {
      final point = points[i];
      final toPoint = point - first;
      final projectionLength = (toPoint.dx * lineVector.dx + toPoint.dy * lineVector.dy) / lineLength;
      final projection = Offset(
        first.dx + (lineVector.dx / lineLength) * projectionLength,
        first.dy + (lineVector.dy / lineLength) * projectionLength,
      );
      final distance = (point - projection).distance;
      
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }
    
    // Si la distancia máxima es menor que la tolerancia, retornar solo los extremos
    if (maxDistance < tolerance) {
      return [first, last];
    }
    
    // Recursión: simplificar ambas partes
    final left = _rdpSimplify(points.sublist(0, maxIndex + 1), tolerance: tolerance);
    final right = _rdpSimplify(points.sublist(maxIndex), tolerance: tolerance);
    
    // Combinar resultados (evitar duplicar el punto de unión)
    return [...left, ...right.sublist(1)];
  }

  /// Suaviza el path usando quadratic bezier
  Path _smoothPath(List<Offset> points, {required bool shouldClose}) {
    if (points.length < 2) {
      return Path();
    }
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      if (shouldClose) {
        path.close();
      }
      return path;
    }
    
    // Usar quadratic bezier para suavizado
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      
      // Punto de control en el medio entre prev y curr
      final controlPoint = Offset(
        (prev.dx + curr.dx) / 2,
        (prev.dy + curr.dy) / 2,
      );
      
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, curr.dx, curr.dy);
    }
    
    if (shouldClose) {
      path.close();
    }
    
    return path;
  }


  /// Calcula el bounding box de un path en coordenadas de imagen
  Rect _calculatePathBounds(Path path) {
    try {
      final bounds = path.getBounds();
      return bounds;
    } catch (e) {
      return Rect.zero;
    }
  }

  /// Calcula el área de un path usando la fórmula shoelace
  double _calculatePathArea(Path path) {
    try {
      // Extraer puntos del path
      final points = <Offset>[];
      final metrics = path.computeMetrics();
      
      for (final metric in metrics) {
        const sampleStep = 10.0; // Muestrear cada 10 px
        final length = metric.length;
        
        for (double offset = 0; offset <= length; offset += sampleStep) {
          final tangent = metric.getTangentForOffset(offset.clamp(0.0, length));
          if (tangent != null) {
            points.add(tangent.position);
          }
        }
      }
      
      if (points.length < 3) {
        return 0.0;
      }
      
      // Shoelace formula
      double area = 0.0;
      for (int i = 0; i < points.length; i++) {
        final j = (i + 1) % points.length;
        area += points[i].dx * points[j].dy;
        area -= points[j].dx * points[i].dy;
      }
      
      return (area.abs() / 2.0);
    } catch (e) {
      return 0.0;
    }
  }

  void setColorMode(ColorMode mode) {
    _colorMode = mode;
    notifyListeners();
    // El recálculo de métricas se dispara desde la UI cuando detecta el cambio
  }

  void setWatermarkVisible(bool visible) {
    _watermarkVisible = visible;
    notifyListeners();
  }

  void setWatermarkIsText(bool isText) {
    _watermarkIsText = isText;
    if (_activeTool == EditorTool.watermark && _watermarkGeometry != null) {
      _activeTransformTarget = isText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
    }
    notifyListeners();
  }

  /// Inicializa un watermark por defecto si no existe
  void initializeWatermarkIfNeeded(Size canvasSize) {
    if (_watermarkGeometry == null) {
      _watermarkGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: Offset(canvasSize.width * 0.5, canvasSize.height * 0.5),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      if (_activeTool == EditorTool.watermark) {
        _activeTransformTarget = _watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo;
      }
      notifyListeners();
    }
  }

  /// Crea un snapshot del estado actual
  EditorSnapshot _createSnapshot() {
    return EditorSnapshot(
      activeTool: _activeTool,
      cropPreset: _cropPreset,
      activeTransformTarget: _activeTransformTarget,
      selectionGeometry: _selectionGeometry != null
          ? TransformableGeometry(
              shape: _selectionGeometry!.shape,
              center: _selectionGeometry!.center,
              size: _selectionGeometry!.size,
              rotation: _selectionGeometry!.rotation,
            )
          : null,
      watermarkGeometry: _watermarkGeometry != null
          ? TransformableGeometry(
              shape: _watermarkGeometry!.shape,
              center: _watermarkGeometry!.center,
              size: _watermarkGeometry!.size,
              rotation: _watermarkGeometry!.rotation,
            )
          : null,
    );
  }

  /// Guarda el estado actual en el undo stack
  void pushUndo() {
    final snapshot = _createSnapshot();
    _undoStack.add(snapshot);
    // Limitar a 10 niveles
    if (_undoStack.length > _maxUndoLevels) {
      _undoStack.removeAt(0);
    }
  }

  /// Restaura el último snapshot del undo stack
  void undo() {
    if (_undoStack.isEmpty) return;

    final snapshot = _undoStack.removeLast();
    _activeTool = snapshot.activeTool;
    _cropPreset = snapshot.cropPreset;
    _activeTransformTarget = snapshot.activeTransformTarget;
    _selectionGeometry = snapshot.selectionGeometry != null
        ? TransformableGeometry(
            shape: snapshot.selectionGeometry!.shape,
            center: snapshot.selectionGeometry!.center,
            size: snapshot.selectionGeometry!.size,
            rotation: snapshot.selectionGeometry!.rotation,
          )
        : null;
    _watermarkGeometry = snapshot.watermarkGeometry != null
        ? TransformableGeometry(
            shape: snapshot.watermarkGeometry!.shape,
            center: snapshot.watermarkGeometry!.center,
            size: snapshot.watermarkGeometry!.size,
            rotation: snapshot.watermarkGeometry!.rotation,
          )
        : null;

    notifyListeners();
  }

  /// Stub para requestSave
  void requestSave() {
    // TODO: Implementar lógica de guardado
    notifyListeners();
  }
  
  // Métodos para ajustes clásicos
  void setActiveClassicAdjustment(ClassicAdjustment? adjustment) {
    _activeClassicAdjustment = adjustment;
    notifyListeners();
  }
  
  void setBrightness(double value) {
    _brightness = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setContrast(double value) {
    _contrast = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setSaturation(double value) {
    _saturation = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setSharpness(double value) {
    _sharpness = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  // Métodos para intensidades de efectos
  void setBlurIntensity(double value) {
    _blurIntensity = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setPixelateIntensity(double value) {
    _pixelateIntensity = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setWatermarkOpacity(double value) {
    _watermarkOpacity = value.clamp(0.0, 100.0);
    notifyListeners();
  }

  /// Establece la extensión del archivo original (fija)
  void setOriginalFileExtension(String? extension) {
    _originalFileExtension = extension;
    notifyListeners();
  }

  /// Establece el nombre base de la versión de selección (editable, sin extensión)
  void setSelectionVersionBaseName(String? baseName) {
    _selectionVersionBaseName = baseName;
    notifyListeners();
  }

  /// Inicializa el nombre base de la versión si no existe
  void initializeSelectionVersionNameIfNeeded(String originalFileName) {
    if (_selectionVersionBaseName == null) {
      // Extraer nombre base sin extensión
      final dotIndex = originalFileName.lastIndexOf('.');
      final baseName = dotIndex > 0 
          ? originalFileName.substring(0, dotIndex)
          : originalFileName;
      _selectionVersionBaseName = baseName;
      
      // Extraer extensión
      if (dotIndex > 0 && dotIndex < originalFileName.length - 1) {
        _originalFileExtension = originalFileName.substring(dotIndex);
      } else {
        _originalFileExtension = '';
      }
      notifyListeners();
    }
  }

  /// Establece el mensaje de estado para la barra blanca
  void setStatusMessage(String? message) {
    _statusMessage = message;
    notifyListeners();
  }

  /// Establece el texto estructurado de la barra blanca
  void setStructuredInfoText(String? text) {
    if (_structuredInfoText == text) return;
    _structuredInfoText = text;
    final newMode = (text != null && text.isNotEmpty) 
        ? WhiteBarMode.structured 
        : WhiteBarMode.support;
    if (_whiteBarMode != newMode) {
      _whiteBarMode = newMode;
    }
    notifyListeners();
  }

  /// Establece el mensaje de soporte de la barra blanca
  void setSupportMessageText(String? text) {
    if (_supportMessageText == text) return;
    _supportMessageText = text;
    if (_structuredInfoText == null || _structuredInfoText!.isEmpty) {
      if (_whiteBarMode != WhiteBarMode.support) {
        _whiteBarMode = WhiteBarMode.support;
      }
    }
    notifyListeners();
  }

  /// Invierte el estado de selección (interior/exterior)
  void toggleSelectionInverted() {
    _selectionInverted = !_selectionInverted;
    notifyListeners();
  }

  /// Actualiza métricas aproximadas para selección
  /// 
  /// Calcula WxH px y ~MB de forma aproximada y rápida.
  /// Usa throttle de 50ms para evitar actualizaciones excesivas durante drag/resize.
  void updateSelectionApproxMetrics({
    required int? imgW,
    required int? imgH,
    required int? originalBytes,
    required String? extensionLower,
    required Size? canvasSize,
  }) {
    // Cancelar timer anterior
    _selectionThrottleTimer?.cancel();
    
    // Si no hay datos necesarios, limpiar métricas
    if (imgW == null || imgH == null || originalBytes == null || 
        extensionLower == null || canvasSize == null) {
      _approxWidthPx = 0;
      _approxHeightPx = 0;
      _approxBytes = 0;
      _approxLabelLeft = null;
      notifyListeners();
      return;
    }
    
    // Verificar si hay selección válida
    final hasSelection = _selectionGeometry != null || _freehandPathImage != null;
    if (!hasSelection) {
      _approxWidthPx = 0;
      _approxHeightPx = 0;
      _approxBytes = 0;
      _approxLabelLeft = null;
      notifyListeners();
      return;
    }

    // Programar con throttle
    final imgWValue = imgW;
    final imgHValue = imgH;
    final originalBytesValue = originalBytes;
    final extensionLowerValue = extensionLower;
    final canvasSizeValue = canvasSize;
    
    _selectionThrottleTimer = Timer(_selectionThrottleDelay, () {
      _performSelectionApproxMetrics(
        imgW: imgWValue,
        imgH: imgHValue,
        originalBytes: originalBytesValue,
        extensionLower: extensionLowerValue,
        canvasSize: canvasSizeValue,
      );
    });
  }

  /// Realiza el cálculo aproximado de métricas para selección
  void _performSelectionApproxMetrics({
    required int imgW,
    required int imgH,
    required int originalBytes,
    required String extensionLower,
    required Size canvasSize,
  }) {
    // Verificar si es selección libre o geométrica
    if (_freehandPathImage != null && _freehandBoundsImagePx != null) {
      // Selección libre
      final bounds = _freehandBoundsImagePx!;
      
      int outW, outH;
      double selectionArea;
      
      if (_selectionInverted) {
        // Exterior: mantener toda la imagen
        outW = imgW;
        outH = imgH;
        selectionArea = imgW * imgH.toDouble();
      } else {
        // Interior: usar bounding box del path
        outW = bounds.width.toInt().clamp(0, imgW);
        outH = bounds.height.toInt().clamp(0, imgH);
        
        // Calcular área aproximada usando shoelace formula
        selectionArea = _calculatePathArea(_freehandPathImage!);
        if (selectionArea <= 0) {
          // Fallback: usar área del bounding box con factor 0.85
          selectionArea = bounds.width * bounds.height * 0.85;
        }
      }
      
      // Calcular ~MB aproximado
      final imageArea = imgW * imgH.toDouble();
      final pixelRatio = imageArea > 0 ? selectionArea / imageArea : 0.0;
      
      // formatFactor según extensión
      double formatFactor = 1.0;
      if (extensionLower == '.png') {
        formatFactor = 1.05;
      } else if (extensionLower == '.jpg' || extensionLower == '.jpeg') {
        formatFactor = 0.95;
      }
      
      final estimatedBytes = math.max(8192, (originalBytes * pixelRatio * formatFactor).toInt());
      
      // Actualizar estado
      _approxWidthPx = outW;
      _approxHeightPx = outH;
      _approxBytes = estimatedBytes;
      
      final baseName = _selectionVersionBaseName ?? 'imagen';
      _approxLabelLeft = 'Selección: $baseName$extensionLower';
      
      notifyListeners();
      return;
    }
    
    if (_selectionGeometry == null) {
      _approxWidthPx = 0;
      _approxHeightPx = 0;
      _approxBytes = 0;
      _approxLabelLeft = null;
      notifyListeners();
      return;
    }

    final geometry = _selectionGeometry!;
    
    // Mapear geometría del canvas a coordenadas de imagen usando BoxFit.contain
    final imageSize = Size(imgW.toDouble(), imgH.toDouble());
    final imageRect = _calculateImageRectInCanvas(canvasSize, imageSize);
    
    // Calcular escala y offset
    final scaleX = imgW / imageRect.width;
    final scaleY = imgH / imageRect.height;
    
    // Mapear coordenadas del canvas a coordenadas relativas a imageRect
    final relativeCenter = Offset(
      geometry.center.dx - imageRect.left,
      geometry.center.dy - imageRect.top,
    );
    
    // Escalar a coordenadas de imagen
    final scaledCenter = Offset(
      relativeCenter.dx * scaleX,
      relativeCenter.dy * scaleY,
    );
    final scaledSize = Size(
      geometry.size.width * scaleX,
      geometry.size.height * scaleY,
    );
    
    final scaledGeometry = TransformableGeometry(
      shape: geometry.shape,
      center: scaledCenter,
      size: scaledSize,
      rotation: geometry.rotation,
    );
    
    final rectInImage = scaledGeometry.boundingBox;
    final rectClamped = Rect.fromLTWH(
      rectInImage.left.clamp(0.0, imgW.toDouble()),
      rectInImage.top.clamp(0.0, imgH.toDouble()),
      rectInImage.width.clamp(0.0, (imgW - rectInImage.left).clamp(0.0, imgW.toDouble())),
      rectInImage.height.clamp(0.0, (imgH - rectInImage.top).clamp(0.0, imgH.toDouble())),
    );

    // Calcular WxH px
    int outW, outH;
    double selectionArea;
    
    if (_selectionInverted) {
      // Exterior: mantener toda la imagen
      outW = imgW;
      outH = imgH;
      selectionArea = imgW * imgH.toDouble();
    } else {
      // Interior: recortar a la selección
      if (geometry.shape == TransformableShape.circle) {
        final radius = math.min(rectClamped.width, rectClamped.height) / 2;
        outW = (radius * 2).toInt();
        outH = (radius * 2).toInt();
        // Área del círculo: π * r²
        selectionArea = math.pi * radius * radius;
      } else {
        outW = rectClamped.width.toInt();
        outH = rectClamped.height.toInt();
        // Área del rectángulo: w * h
        selectionArea = outW * outH.toDouble();
      }
    }

    // Calcular ~MB aproximado
    // pixelRatio = selectionArea / imageArea
    final imageArea = imgW * imgH.toDouble();
    final pixelRatio = imageArea > 0 ? selectionArea / imageArea : 0.0;
    
    // formatFactor según extensión
    double formatFactor = 1.0;
    if (extensionLower == '.png') {
      formatFactor = 1.05;
    } else if (extensionLower == '.jpg' || extensionLower == '.jpeg') {
      formatFactor = 0.95;
    }
    
    final estimatedBytes = math.max(8192, (originalBytes * pixelRatio * formatFactor).toInt());
    
    // Actualizar estado
    _approxWidthPx = outW;
    _approxHeightPx = outH;
    _approxBytes = estimatedBytes;
    
    final baseName = _selectionVersionBaseName ?? 'imagen';
    _approxLabelLeft = 'Selección: $baseName$extensionLower';
    
    notifyListeners();
  }

  /// Actualiza métricas aproximadas para color preset
  /// 
  /// Calcula ~MB de forma aproximada e instantánea.
  void updateColorApproxMetrics({
    required int? imgW,
    required int? imgH,
    required int? originalBytes,
    required String? extensionLower,
    required ColorMode preset,
  }) {
    // Si no hay datos necesarios, limpiar métricas
    if (imgW == null || imgH == null || originalBytes == null || 
        extensionLower == null) {
      _approxWidthPx = 0;
      _approxHeightPx = 0;
      _approxBytes = 0;
      _approxLabelLeft = null;
      notifyListeners();
      return;
    }

    // WxH = imgW×imgH
    _approxWidthPx = imgW;
    _approxHeightPx = imgH;

    // Calcular presetFactor según preset y formato
    double presetFactor = 1.0;
    if (preset == ColorMode.grayscale) {
      presetFactor = (extensionLower == '.png') ? 0.85 : 0.90;
    } else if (preset == ColorMode.sepia) {
      presetFactor = (extensionLower == '.png') ? 0.95 : 0.97;
    } else if (preset == ColorMode.blackAndWhite) {
      presetFactor = (extensionLower == '.png') ? 0.80 : 0.88;
    } else {
      // Color: 1.00
      presetFactor = 1.00;
    }

    final estimatedBytes = math.max(8192, (originalBytes * presetFactor).toInt());
    
    // Actualizar estado
    _approxBytes = estimatedBytes;
    
    String presetName;
    switch (preset) {
      case ColorMode.grayscale:
        presetName = 'Grises';
        break;
      case ColorMode.sepia:
        presetName = 'Sepia';
        break;
      case ColorMode.blackAndWhite:
        presetName = 'B&N';
        break;
      case ColorMode.color:
        presetName = 'Color';
        break;
    }
    _approxLabelLeft = 'Color: $presetName';
    
    notifyListeners();
  }

  /// Establece el tamaño del canvas para mapeo
  void setCanvasSize(Size? size) {
    _canvasSize = size;
  }

  /// Calcula el rect de la imagen dentro del canvas usando BoxFit.contain
  /// 
  /// Retorna el rectángulo donde se renderiza la imagen dentro del canvas,
  /// respetando el aspect ratio y centrándola.
  Rect _calculateImageRectInCanvas(Size canvasSize, Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
    }

    final imageAspect = imageSize.width / imageSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double width, height;
    if (imageAspect > canvasAspect) {
      // Imagen más ancha: ajustar al ancho del canvas
      width = canvasSize.width;
      height = width / imageAspect;
    } else {
      // Imagen más alta: ajustar al alto del canvas
      height = canvasSize.height;
      width = height * imageAspect;
    }

    // Centrar
    final left = (canvasSize.width - width) / 2;
    final top = (canvasSize.height - height) / 2;

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  void dispose() {
    _selectionThrottleTimer?.cancel();
    super.dispose();
  }
}

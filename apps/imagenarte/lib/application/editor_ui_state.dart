import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/domain/collage_config.dart';
import 'package:imagenarte/domain/watermark_config.dart';

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
  geometricSelection, // RESTAURADO: Herramienta de selección geométrica
  freeSelection,
  scissors,
  collage,
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
  selectionRatios, // RESTAURADO: Overlay de selección geométrica
  freeSelection,
  scissors,
  collage,
  colorPresets,
  classicAdjustments,
  action_blur,
  action_pixelate,
  action_watermark,
  action_metadata,
  zoom,
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
  final WatermarkConfig? watermarkConfig; // Configuración completa
  final ColorMode colorMode;
  final double colorIntensity;
  final double blurIntensity;
  // Ajustes clásicos
  final double brightness;
  final double contrast;
  final double saturation;
  final double sharpness;

  EditorSnapshot({
    required this.activeTool,
    required this.cropPreset,
    required this.activeTransformTarget,
    required this.selectionGeometry,
    required this.watermarkConfig,
    required this.colorMode,
    required this.colorIntensity,
    required this.blurIntensity,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.sharpness,
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
  
  // Configuración completa de watermark
  WatermarkConfig? _watermarkConfig;
  
  // Campos legacy para compatibilidad (se mantienen mientras migramos)
  TransformableGeometry? get _watermarkGeometry => _watermarkConfig?.transform;
  bool get _watermarkVisible => _watermarkConfig?.enabled ?? false;
  bool get _watermarkIsText => _watermarkConfig?.type == WatermarkType.text;
  
  // Timer para debounce de transformaciones (drag continuo)
  Timer? _watermarkTransformDebounceTimer;
  static const Duration _watermarkTransformDebounceDelay = Duration(milliseconds: 300);

  // Color mode
  ColorMode _colorMode = ColorMode.color;
  double _colorIntensity = 100.0; // 0-100, intensidad del filtro de color
  
  // Classic adjustments
  ClassicAdjustment? _activeClassicAdjustment;
  double _brightness = 0.0; // -100..+100, default 0
  double _contrast = 0.0; // -100..+100, default 0
  double _saturation = 0.0; // -100..+100, default 0
  double _sharpness = 0.0; // 0..100, default 0
  
  // Estado de preview para ajustes clásicos
  bool _isPreviewingClassicAdjustments = false;
  
  // Timer para throttle de preview durante drag
  Timer? _classicAdjustmentsThrottleTimer;
  static const Duration _classicAdjustmentsThrottleDelay = Duration(milliseconds: 33); // ~30fps
  
  // Intensidades de efectos (0-100)
  double _blurIntensity = 50.0; // 0-100
  double _pixelateIntensity = 50.0; // 0-100
  double get _watermarkOpacity => (_watermarkConfig?.opacity ?? 0.35) * 100.0; // Convertir 0-1 a 0-100

  // Estado de eliminación de metadatos (por defecto ON)
  bool _metadataRemovalEnabled = true;

  // Estado de zoom (vista/preview)
  bool _zoomUiVisible = false;
  double _zoomT = 0.0; // [-1.0 .. +1.0]
  double _zoomScale = 1.0; // 0.5 .. 3.0
  Offset _zoomOffset = Offset.zero; // Offset para pan cuando hay zoom

  // Configuración de collage
  CollageConfig _collageConfig = const CollageConfig(
    layoutType: CollageLayoutType.grid,
    rows: 4,
    cols: 3,
    spacing: 4.0,
    padding: 0.0,
  );

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
  
  // Timer para auto-cierre de herramientas
  Timer? _toolAutoCloseTimer;
  static const Duration _toolAutoCloseDelay = Duration(milliseconds: 3000); // 3 segundos después de dejar de usar
  static const Duration _toolInitialCloseDelay = Duration(milliseconds: 10000); // 10 segundos desde que se abre
  bool _toolHasBeenUsed = false; // Flag para saber si la herramienta ha sido usada

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
  // Getters para watermark (compatibilidad + nuevos)
  TransformableGeometry? get watermarkGeometry => _watermarkGeometry;
  bool get watermarkVisible => _watermarkVisible;
  bool get watermarkIsText => _watermarkIsText;
  WatermarkConfig? get watermarkConfig => _watermarkConfig;
  ColorMode get colorMode => _colorMode;
  double get colorIntensity => _colorIntensity;
  ClassicAdjustment? get activeClassicAdjustment => _activeClassicAdjustment;
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get sharpness => _sharpness;
  double get blurIntensity => _blurIntensity;
  double get pixelateIntensity => _pixelateIntensity;
  double get watermarkOpacity => _watermarkOpacity;
  bool get metadataRemovalEnabled => _metadataRemovalEnabled;
  bool get zoomUiVisible => _zoomUiVisible;
  double get zoomT => _zoomT;
  double get zoomScale => _zoomScale;
  Offset get zoomOffset => _zoomOffset;
  CollageConfig get collageConfig => _collageConfig;
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
    
    // Ocultar zoom si se cambia a un contexto diferente
    if (ctx != EditorContext.zoom && _zoomUiVisible) {
      hideZoomUi();
    }
    
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
    // Cancelar timer de auto-cierre anterior PRIMERO (IMPORTANTE: hacerlo al inicio)
    _toolAutoCloseTimer?.cancel();
    _toolAutoCloseTimer = null;
    _toolHasBeenUsed = false; // Resetear flag ANTES de iniciar nueva herramienta
    
    // Undo y Save no cambian el tool activo, solo ejecutan acciones
    if (tool == EditorTool.undo) {
      undo();
      return;
    }
    if (tool == EditorTool.save) {
      requestSave();
      // Salida de foco: limpiar activeAction y contexto
      exitTool(); // Resetear herramienta actual antes de salir
      _activeAction = null;
      setContext(EditorContext.none);
      _activeTool = EditorTool.none;
      notifyListeners();
      return;
    }
    
    // Home limpia activeAction y contexto (salida de foco)
    if (tool == EditorTool.home) {
      exitTool(); // Resetear herramienta actual antes de salir
      _activeAction = null;
      setContext(EditorContext.none);
      _activeTool = tool;
      notifyListeners();
      return;
    }
    
    // Si se cambia de herramienta, salir de la anterior (RESET TOTAL)
    if (_activeTool != tool && _activeTool != EditorTool.none && _activeTool != EditorTool.home) {
      exitTool(); // Reset completo de la herramienta anterior
    }
    
    // Ocultar zoom al cambiar de herramienta (excepto si es el mismo tool)
    if (_activeTool != tool) {
      hideZoomUi();
    }
    
    _activeTool = tool;
    
    // Mapear tool a contexto y establecerlo (esto reemplaza cualquier contexto anterior)
    switch (tool) {
      case EditorTool.geometricSelection:
        // Selección geométrica (rectángulo/círculo)
        setContext(EditorContext.selectionRatios);
        break;
      case EditorTool.freeSelection:
        // Selección libre (mano alzada)
        setContext(EditorContext.freeSelection);
        break;
      case EditorTool.scissors:
        // La tijera muestra overlay para elegir Interior/Exterior
        setContext(EditorContext.scissors);
        break;
      case EditorTool.collage:
        setContext(EditorContext.collage);
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
    
    // Lógica para herramientas
    if (tool == EditorTool.color || tool == EditorTool.classicAdjustments) {
      // Color y ajustes no usan transform target
      _activeTransformTarget = TransformTarget.none;
      // Establecer preset Original por defecto al abrir la herramienta
      if (tool == EditorTool.color && _colorMode == ColorMode.color) {
        // Solo si ya está en color (primera vez), asegurar intensidad
        _colorIntensity = 100.0;
      }
    } else if (tool == EditorTool.watermark) {
      // Inicializar watermark si no existe
      if (_canvasSize != null) {
        initializeWatermarkIfNeeded(_canvasSize!);
      }
      // Seleccionar automáticamente si hay watermark habilitado
      if (_watermarkConfig != null && _watermarkConfig!.enabled) {
        _activeTransformTarget = _watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo;
      } else {
        _activeTransformTarget = TransformTarget.none;
      }
    } else if (tool == EditorTool.geometricSelection) {
      // Herramienta de selección geométrica: activar transform target si hay selección
      if (_selectionGeometry != null) {
        _activeTransformTarget = TransformTarget.selection;
      } else {
        _activeTransformTarget = TransformTarget.none;
      }
    } else if (tool == EditorTool.blur || tool == EditorTool.pixelate) {
      // Para herramientas que usan selección ROI
      _activeTransformTarget = TransformTarget.selection;
    } else {
      _activeTransformTarget = TransformTarget.none;
    }
    
    // Iniciar timer de auto-cierre inicial (10 segundos si no se usa)
    // Nota: _toolHasBeenUsed ya se reseteó arriba
    _startToolAutoCloseTimer(isInitial: true);
  }
  
  /// Inicia el timer de auto-cierre de la herramienta activa
  /// isInitial: true si es el timer inicial (10 segundos), false si es después de interacción (3 segundos)
  void _startToolAutoCloseTimer({bool isInitial = false}) {
    // Cancelar cualquier timer existente primero (asegurar que se cancela completamente)
    _toolAutoCloseTimer?.cancel();
    _toolAutoCloseTimer = null;
    
    // Usar delay inicial (10s) si no se ha usado la herramienta Y es el timer inicial
    // Si ya se usó o no es inicial, usar delay normal (3s)
    final delay = (!_toolHasBeenUsed && isInitial) 
        ? _toolInitialCloseDelay  // 10 segundos (10000ms)
        : _toolAutoCloseDelay;     // 3 segundos (3000ms)
    
    _toolAutoCloseTimer = Timer(delay, () {
      // Auto-cerrar la herramienta después del delay sin interacción
      if (_activeTool != EditorTool.none && _activeTool != EditorTool.home) {
        exitActiveTool(); // Reset completo y cerrar herramienta
      }
      // Cerrar zoom si está activo (independientemente de si hay herramienta activa)
      if (_zoomUiVisible) {
        hideZoomUi();
        // Si hay herramienta activa, también cerrarla
        if (_activeTool != EditorTool.none && _activeTool != EditorTool.home) {
          exitActiveTool();
        }
      }
    });
  }
  
  /// Reinicia el timer de auto-cierre (llamar cuando hay interacción del usuario)
  void resetToolAutoCloseTimer() {
    // Reiniciar timer si hay herramienta activa
    if (_activeTool != EditorTool.none && _activeTool != EditorTool.home) {
      _toolHasBeenUsed = true; // Marcar que la herramienta ha sido usada
      _startToolAutoCloseTimer(isInitial: false); // Usar delay de 3 segundos
    }
    // Reiniciar timer si el zoom está activo (independientemente de herramienta)
    if (_zoomUiVisible) {
      _toolHasBeenUsed = true;
      _startToolAutoCloseTimer(isInitial: false);
    }
  }

  void toggleTool(EditorTool tool) {
    // Cancelar timer de auto-cierre anterior
    _toolAutoCloseTimer?.cancel();
    _toolAutoCloseTimer = null;
    
    // Verificar si es una acción de la Action List
    final isActionListTool = tool == EditorTool.blur ||
        tool == EditorTool.pixelate ||
        tool == EditorTool.watermark ||
        tool == EditorTool.metadata;
    
    if (isActionListTool) {
      // Si se toca la misma acción, salir de foco (RESET COMPLETO)
      if (_activeAction == tool) {
        exitTool(clearSelection: true); // Reset completo antes de salir
        _activeAction = null;
        _activeTool = EditorTool.none;
        setContext(EditorContext.none);
      } else {
        // Cambiar foco a la nueva acción (SIEMPRE resetear la anterior)
        exitTool(clearSelection: true); // Reset completo de la anterior
        _activeAction = tool;
        setActiveTool(tool); // Esto ya resetea y abre la nueva
      }
      return;
    }
    
    // Para otras herramientas: SIEMPRE resetear antes de cambiar (incluso si es la misma)
    if (_activeTool == tool) {
      // Si se toca el mismo tool, resetearlo completamente y cerrar contexto
      exitTool(clearSelection: true); // Reset completo antes de salir
      _activeTool = EditorTool.none;
      setContext(EditorContext.none);
    } else {
      // Activar el nuevo tool (esto SIEMPRE resetea la anterior y abre la nueva)
      setActiveTool(tool);
    }
  }

  /// Sale de la herramienta activa: resetea estado transitorio y limpia cache
  /// Se llama ANTES de cambiar a otra herramienta o al salir completamente
  /// 
  /// REGLA CANÓNICA: Al salir de una herramienta, se resetea completamente:
  /// - Parámetros temporales (sliders, dials) vuelven a default
  /// - Selecciones temporales se limpian (pero NO resultados ya aplicados)
  /// - Previews y buffers se vacían
  /// - Timers se cancelan
  void exitTool({EditorTool? specificTool, bool clearSelection = false}) {
    final toolToExit = specificTool ?? _activeTool;
    
    if (toolToExit == EditorTool.none || toolToExit == EditorTool.home) {
      return;
    }
    
    // Resetear estado específico de la herramienta
    _resetTool(toolToExit);
    
    // Limpiar estados transitorios comunes (selecciones temporales, paths, etc.)
    if (toolToExit == EditorTool.freeSelection) {
      // Limpiar selección libre temporal (puntos en tiempo real durante dibujo)
      _freehandPointsCanvas.clear();
      _isDrawingFreehand = false;
      // Si clearSelection es true, también limpiar paths finales (solo al salir completamente)
      if (clearSelection) {
        _freeSelectionPath = null;
        _freehandPathCanvas = null;
        _freehandPathImage = null;
        _freehandBoundsImagePx = null;
      }
      // NO limpiar paths finales por defecto porque son resultados aplicados
    }
    
    // Limpiar selección geométrica temporal solo si clearSelection es true
    if (toolToExit == EditorTool.geometricSelection && clearSelection) {
      // Reset total: limpiar selección geométrica al salir de la herramienta
      _selectionGeometry = null;
      _activeTransformTarget = TransformTarget.none;
      _cropPreset = null; // Resetear preset también
    }
    if ((toolToExit == EditorTool.blur || toolToExit == EditorTool.pixelate) && clearSelection) {
      // Solo limpiar selección si se sale completamente (no al cambiar entre blur/pixelate)
      _selectionGeometry = null;
      _activeTransformTarget = TransformTarget.none;
    }
    
    // Limpiar transform target si corresponde
    if (toolToExit == EditorTool.watermark) {
      _activeTransformTarget = TransformTarget.none;
    }
    
    // Cancelar todos los timers pendientes
    _selectionThrottleTimer?.cancel();
    _selectionThrottleTimer = null;
    // NO cancelar _toolAutoCloseTimer aquí porque podría estar en uso por la nueva herramienta
    
    notifyListeners();
  }
  
  /// Sale de la herramienta activa y desactiva todas las herramientas
  /// Útil para ESC o click fuera
  /// 
  /// REGLA: Limpia TODO el estado transitorio (incluyendo selecciones temporales)
  void exitActiveTool() {
    // Cancelar timer de auto-cierre
    _toolAutoCloseTimer?.cancel();
    _toolAutoCloseTimer = null;
    _toolHasBeenUsed = false;
    
    if (_activeTool == EditorTool.none || _activeTool == EditorTool.home) {
      // Si no hay herramienta activa pero hay zoom, cerrarlo
      if (_zoomUiVisible) {
        hideZoomUi();
      }
      return;
    }
    
    // Reset completo con limpieza de selecciones temporales
    exitTool(clearSelection: true);
    
    _activeTool = EditorTool.none;
    _activeAction = null;
    _activeTransformTarget = TransformTarget.none;
    setContext(EditorContext.none);
    
    // También cerrar zoom si está activo
    if (_zoomUiVisible) {
      hideZoomUi();
    }
    
    notifyListeners();
  }

  /// Resetea el estado interno de una herramienta específica
  /// Limpia parámetros temporales, previews, buffers, timers
  void _resetTool(EditorTool tool) {
    switch (tool) {
      case EditorTool.color:
        _colorMode = ColorMode.color;
        _colorIntensity = 100.0; // Resetear intensidad a default
        break;
      case EditorTool.classicAdjustments:
        _brightness = 0.0;
        _contrast = 0.0;
        _saturation = 0.0;
        _sharpness = 0.0;
        _activeClassicAdjustment = null;
        _isPreviewingClassicAdjustments = false;
        _classicAdjustmentsThrottleTimer?.cancel();
        _classicAdjustmentsThrottleTimer = null;
        break;
      case EditorTool.watermark:
        // NO resetear watermark completo aquí (mantener configuración)
        // Solo limpiar estado de transformación temporal
        _activeTransformTarget = TransformTarget.none;
        _watermarkTransformDebounceTimer?.cancel();
        _watermarkTransformDebounceTimer = null;
        break;
      case EditorTool.blur:
        _blurIntensity = 50.0; // Resetear intensidad a default
        break;
      case EditorTool.pixelate:
        _pixelateIntensity = 50.0; // Resetear intensidad a default
        break;
      case EditorTool.geometricSelection:
        // Reset total: limpiar selección geométrica y preset
        _selectionGeometry = null;
        _activeTransformTarget = TransformTarget.none;
        _cropPreset = null;
        break;
      case EditorTool.freeSelection:
        // Limpiar estado de dibujo temporal
        _freehandPointsCanvas.clear();
        _isDrawingFreehand = false;
        // NO limpiar paths finales (son resultado, no estado transitorio)
        break;
      case EditorTool.scissors:
        // Limpiar estado de inversión temporal (volver a default)
        _selectionInverted = false;
        break;
      case EditorTool.collage:
        // Resetear configuración de collage a defaults
        _collageConfig = const CollageConfig(
          layoutType: CollageLayoutType.grid,
          rows: 4,
          cols: 3,
          spacing: 4.0,
          padding: 0.0,
        );
        break;
      case EditorTool.metadata:
        // Resetear estado de metadatos a default
        _metadataRemovalEnabled = true;
        break;
      default:
        // Otros tools no tienen estado que resetear
        break;
    }
  }

  void setCropPreset(CropPreset preset) {
    _cropPreset = preset;
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    notifyListeners();
  }

  void setActiveTransformTarget(TransformTarget target) {
    _activeTransformTarget = target;
    notifyListeners();
  }

  void setWatermarkGeometry(TransformableGeometry? geometry) {
    if (geometry == null) {
      _watermarkConfig = null;
    } else {
      _watermarkConfig = (_watermarkConfig ?? _createDefaultWatermarkConfig(geometry))
          .copyWith(transform: geometry);
    }
    if (geometry != null && _activeTool == EditorTool.watermark) {
      _activeTransformTarget = _watermarkIsText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
    }
    notifyListeners();
  }

  void updateWatermarkGeometry(TransformableGeometry geometry) {
    if (_watermarkConfig == null) {
      _watermarkConfig = _createDefaultWatermarkConfig(geometry);
    } else {
      _watermarkConfig = _watermarkConfig!.copyWith(transform: geometry);
    }
    
    // Debounce para drag continuo: solo commit undo al final
    _watermarkTransformDebounceTimer?.cancel();
    _watermarkTransformDebounceTimer = Timer(_watermarkTransformDebounceDelay, () {
      pushUndo();
    });
    
    notifyListeners();
  }

  /// Commitea la transformación del watermark inmediatamente (al soltar)
  /// Cancela el debounce y hace pushUndo inmediatamente
  void commitWatermarkTransform() {
    _watermarkTransformDebounceTimer?.cancel();
    pushUndo();
  }
  
  /// Crea configuración por defecto de watermark
  WatermarkConfig _createDefaultWatermarkConfig(TransformableGeometry geometry) {
    return WatermarkConfig(
      enabled: true,
      type: WatermarkType.text,
      text: '@imagenarte',
      opacity: 0.35,
      color: const Color(0xFFFFFFFF),
      transform: geometry,
      locked: false,
      anchorPreset: WatermarkAnchorPreset.custom,
      safeMargin: 0.03,
    );
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
  /// Crea una selección basada en el preset activo (o rectángulo por defecto)
  void initializeGeometricSelection(Size canvasSize, Size? imageSize) {
    if (_selectionGeometry != null) {
      return; // Ya existe una selección
    }
    
    final imageSizeToUse = imageSize ?? canvasSize;
    final center = Offset(canvasSize.width * 0.5, canvasSize.height * 0.5);
    
    TransformableGeometry geometry;
    
    if (_cropPreset == CropPreset.circular) {
      // Círculo centrado
      final radius = math.min(canvasSize.width, canvasSize.height) * 0.2;
      geometry = TransformableGeometry(
        shape: TransformableShape.circle,
        center: center,
        size: Size(radius * 2, radius * 2),
        rotation: 0.0,
      );
    } else {
      // Rectángulo con proporción según preset
      double aspectRatio;
      switch (_cropPreset) {
        case CropPreset.p9_16:
          aspectRatio = 9.0 / 16.0;
          break;
        case CropPreset.p1_1:
          aspectRatio = 1.0;
          break;
        case CropPreset.p16_9:
          aspectRatio = 16.0 / 9.0;
          break;
        case CropPreset.p4_3:
          aspectRatio = 4.0 / 3.0;
          break;
        default:
          aspectRatio = imageSizeToUse.width / imageSizeToUse.height; // Proporción original
      }
      
      // Calcular tamaño manteniendo proporción
      final maxWidth = canvasSize.width * 0.6;
      final maxHeight = canvasSize.height * 0.6;
      
      double width, height;
      if (aspectRatio > 1.0) {
        // Ancho mayor
        width = math.min(maxWidth, maxHeight * aspectRatio);
        height = width / aspectRatio;
      } else {
        // Alto mayor
        height = math.min(maxHeight, maxWidth / aspectRatio);
        width = height * aspectRatio;
      }
      
      geometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: center,
        size: Size(width, height),
        rotation: 0.0,
      );
    }
    
    _selectionGeometry = geometry;
    _activeTransformTarget = TransformTarget.selection;
    _selectionMode = SelectionMode.geometric;
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

  void updateSelectionGeometry(TransformableGeometry? geometry) {
    _selectionGeometry = geometry;
    if (geometry != null) {
      _activeTransformTarget = TransformTarget.selection;
    }
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    notifyListeners();
    // El recálculo de métricas se dispara desde la UI cuando detecta el cambio
  }

  /// Inicia la creación de una selección geométrica (drag desde un punto)
  void startGeometricSelection(Offset startPoint) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    // Si ya hay una selección y el punto está dentro, no crear nueva (dejar que TransformTool maneje)
    if (_selectionGeometry != null && _selectionGeometry!.containsPoint(startPoint)) {
      return;
    }
    
    // Crear nueva selección: rectángulo por defecto (o según preset)
    final shape = _cropPreset == CropPreset.circular 
        ? TransformableShape.circle 
        : TransformableShape.rect;
    
    _selectionGeometry = TransformableGeometry(
      shape: shape,
      center: startPoint,
      size: const Size(0, 0), // Empezar con tamaño 0, se actualizará en update
      rotation: 0.0,
    );
    _activeTransformTarget = TransformTarget.selection;
    _selectionMode = SelectionMode.geometric;
    notifyListeners();
  }

  /// Actualiza la selección geométrica durante el drag (creación)
  void updateGeometricSelectionDrag(Offset currentPoint, Offset startPoint) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    if (_selectionGeometry == null) return;
    
    // Calcular tamaño y centro basado en startPoint y currentPoint
    final width = (currentPoint.dx - startPoint.dx).abs();
    final height = (currentPoint.dy - startPoint.dy).abs();
    
    // Mínimo tamaño para evitar selecciones demasiado pequeñas
    const minSize = 20.0;
    final finalWidth = math.max(width, minSize);
    final finalHeight = math.max(height, minSize);
    
    // Calcular centro
    final center = Offset(
      (startPoint.dx + currentPoint.dx) / 2,
      (startPoint.dy + currentPoint.dy) / 2,
    );
    
    // Si es círculo, mantener proporción (usar el menor de los dos)
    if (_selectionGeometry!.shape == TransformableShape.circle) {
      final size = math.min(finalWidth, finalHeight);
      _selectionGeometry = _selectionGeometry!.copyWith(
        center: center,
        size: Size(size, size),
      );
    } else {
      // Rectángulo: mantener proporción si hay preset activo
      double aspectRatio = 1.0;
      if (_cropPreset != null && _cropPreset != CropPreset.circular) {
        switch (_cropPreset) {
          case CropPreset.p9_16:
            aspectRatio = 9.0 / 16.0;
            break;
          case CropPreset.p1_1:
            aspectRatio = 1.0;
            break;
          case CropPreset.p16_9:
            aspectRatio = 16.0 / 9.0;
            break;
          case CropPreset.p4_3:
            aspectRatio = 4.0 / 3.0;
            break;
          default:
            aspectRatio = finalWidth / finalHeight; // Sin restricción
        }
        
        // Aplicar proporción
        double newWidth, newHeight;
        if (aspectRatio > 1.0) {
          newWidth = finalWidth;
          newHeight = finalWidth / aspectRatio;
        } else {
          newHeight = finalHeight;
          newWidth = finalHeight * aspectRatio;
        }
        
        _selectionGeometry = _selectionGeometry!.copyWith(
          center: center,
          size: Size(newWidth, newHeight),
        );
      } else {
        // Sin preset: rectángulo libre
        _selectionGeometry = _selectionGeometry!.copyWith(
          center: center,
          size: Size(finalWidth, finalHeight),
        );
      }
    }
    
    notifyListeners();
  }

  /// Finaliza la creación de selección geométrica
  void endGeometricSelectionDrag() {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    // Validar que la selección tenga un tamaño mínimo
    if (_selectionGeometry != null) {
      const minSize = 20.0;
      if (_selectionGeometry!.size.width < minSize || 
          _selectionGeometry!.size.height < minSize) {
        // Selección demasiado pequeña: cancelar
        _selectionGeometry = null;
        _activeTransformTarget = TransformTarget.none;
      }
    }
    notifyListeners();
  }

  void setFreeSelectionPath(Path? path) {
    _freeSelectionPath = path;
    notifyListeners();
  }

  /// Inicia el dibujo de selección libre
  void startFreehand() {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    _isDrawingFreehand = true;
    _freehandPointsCanvas.clear();
    notifyListeners();
  }

  /// Agrega un punto durante el dibujo (solo si está dentro del área de la imagen)
  void addFreehandPoint(Offset canvasPoint, Rect? imageDestRect) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
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
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
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
    // Establecer intensidad por defecto según el preset
    switch (mode) {
      case ColorMode.color:
        // Original no usa intensidad, pero mantenemos el valor
        break;
      case ColorMode.grayscale:
        _colorIntensity = 100.0;
        break;
      case ColorMode.sepia:
        _colorIntensity = 70.0;
        break;
      case ColorMode.blackAndWhite:
        _colorIntensity = 85.0;
        break;
    }
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    notifyListeners();
    // El recálculo de métricas se dispara desde la UI cuando detecta el cambio
  }

  void setColorIntensity(double value) {
    _colorIntensity = value.clamp(0.0, 100.0);
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    notifyListeners();
  }

  void resetColorIntensity() {
    // Restaurar intensidad default del preset activo
    switch (_colorMode) {
      case ColorMode.color:
        // Original no hace nada
        break;
      case ColorMode.grayscale:
        _colorIntensity = 100.0;
        break;
      case ColorMode.sepia:
        _colorIntensity = 70.0;
        break;
      case ColorMode.blackAndWhite:
        _colorIntensity = 85.0;
        break;
    }
    notifyListeners();
  }

  void setWatermarkVisible(bool visible) {
    if (_watermarkConfig == null && visible) {
      // Inicializar si no existe
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0), // Se calculará en initializeWatermarkIfNeeded
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    if (_watermarkConfig != null) {
      _watermarkConfig = _watermarkConfig!.copyWith(enabled: visible);
      // Seleccionar automáticamente cuando se habilita
      if (visible && _activeTool == EditorTool.watermark) {
        _activeTransformTarget = _watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo;
      }
      pushUndo();
      notifyListeners();
    }
  }

  void setWatermarkIsText(bool isText) {
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(
      type: isText ? WatermarkType.text : WatermarkType.image,
    );
    if (_activeTool == EditorTool.watermark && _watermarkGeometry != null) {
      _activeTransformTarget = isText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
    }
    pushUndo();
    notifyListeners();
  }
  
  // Nuevos métodos para configuración completa
  void setWatermarkText(String text) {
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(text: text);
    // Seleccionar automáticamente cuando se edita el texto
    if (_activeTool == EditorTool.watermark && _watermarkConfig!.enabled) {
      _activeTransformTarget = TransformTarget.watermarkText;
    }
    pushUndo();
    notifyListeners();
  }
  
  void setWatermarkImagePath(String? imagePath) {
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(
      type: WatermarkType.image,
      imagePath: imagePath,
    );
    pushUndo();
    notifyListeners();
  }
  
  void setWatermarkColor(Color color) {
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(color: color);
    pushUndo();
    notifyListeners();
  }
  
  void setWatermarkOpacity(double value) {
    // value viene en 0-100, convertir a 0-1
    final opacity = (value / 100.0).clamp(0.0, 1.0);
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(opacity: opacity);
    notifyListeners();
  }
  
  void setWatermarkOpacityEnd(double value) {
    setWatermarkOpacity(value);
    pushUndo();
  }
  
  void setWatermarkLocked(bool locked) {
    if (_watermarkConfig == null) return;
    _watermarkConfig = _watermarkConfig!.copyWith(locked: locked);
    pushUndo();
    notifyListeners();
  }
  
  void setWatermarkOutline(WatermarkOutline? outline) {
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(outline: outline);
    pushUndo();
    notifyListeners();
  }
  
  void setWatermarkShadow(WatermarkShadow? shadow) {
    if (_watermarkConfig == null) {
      final defaultGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: const Offset(0, 0),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      _watermarkConfig = _createDefaultWatermarkConfig(defaultGeometry);
    }
    _watermarkConfig = _watermarkConfig!.copyWith(shadow: shadow);
    pushUndo();
    notifyListeners();
  }
  
  /// Aplica un preset de posición (9-grid)
  void applyWatermarkAnchorPreset(WatermarkAnchorPreset preset, Size canvasSize) {
    if (_watermarkConfig == null) return;
    
    final safeMargin = _watermarkConfig!.safeMargin;
    final geometry = _watermarkConfig!.transform;
    final watermarkSize = geometry.size;
    
    Offset newCenter;
    switch (preset) {
      case WatermarkAnchorPreset.topLeft:
        newCenter = Offset(
          watermarkSize.width / 2 + canvasSize.width * safeMargin,
          watermarkSize.height / 2 + canvasSize.height * safeMargin,
        );
        break;
      case WatermarkAnchorPreset.topCenter:
        newCenter = Offset(
          canvasSize.width / 2,
          watermarkSize.height / 2 + canvasSize.height * safeMargin,
        );
        break;
      case WatermarkAnchorPreset.topRight:
        newCenter = Offset(
          canvasSize.width - watermarkSize.width / 2 - canvasSize.width * safeMargin,
          watermarkSize.height / 2 + canvasSize.height * safeMargin,
        );
        break;
      case WatermarkAnchorPreset.middleLeft:
        newCenter = Offset(
          watermarkSize.width / 2 + canvasSize.width * safeMargin,
          canvasSize.height / 2,
        );
        break;
      case WatermarkAnchorPreset.center:
        newCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
        break;
      case WatermarkAnchorPreset.middleRight:
        newCenter = Offset(
          canvasSize.width - watermarkSize.width / 2 - canvasSize.width * safeMargin,
          canvasSize.height / 2,
        );
        break;
      case WatermarkAnchorPreset.bottomLeft:
        newCenter = Offset(
          watermarkSize.width / 2 + canvasSize.width * safeMargin,
          canvasSize.height - watermarkSize.height / 2 - canvasSize.height * safeMargin,
        );
        break;
      case WatermarkAnchorPreset.bottomCenter:
        newCenter = Offset(
          canvasSize.width / 2,
          canvasSize.height - watermarkSize.height / 2 - canvasSize.height * safeMargin,
        );
        break;
      case WatermarkAnchorPreset.bottomRight:
        newCenter = Offset(
          canvasSize.width - watermarkSize.width / 2 - canvasSize.width * safeMargin,
          canvasSize.height - watermarkSize.height / 2 - canvasSize.height * safeMargin,
        );
        break;
      case WatermarkAnchorPreset.custom:
        // No cambiar posición
        _watermarkConfig = _watermarkConfig!.copyWith(anchorPreset: preset);
        pushUndo();
        notifyListeners();
        return;
    }
    
    // Clamp para asegurar que no salga del canvas
    final clampedCenter = Offset(
      newCenter.dx.clamp(watermarkSize.width / 2, canvasSize.width - watermarkSize.width / 2),
      newCenter.dy.clamp(watermarkSize.height / 2, canvasSize.height - watermarkSize.height / 2),
    );
    
    final newGeometry = geometry.copyWith(center: clampedCenter);
    _watermarkConfig = _watermarkConfig!.copyWith(
      transform: newGeometry,
      anchorPreset: preset,
    );
    pushUndo();
    notifyListeners();
  }
  
  /// Resetea el watermark a valores por defecto
  void resetWatermark(Size canvasSize) {
    // Posición por defecto: inferior derecha
    final defaultSize = Size(canvasSize.width * 0.12, canvasSize.height * 0.05);
    final defaultCenter = Offset(
      canvasSize.width - defaultSize.width / 2 - canvasSize.width * 0.03,
      canvasSize.height - defaultSize.height / 2 - canvasSize.height * 0.03,
    );
    
    final defaultGeometry = TransformableGeometry(
      shape: TransformableShape.rect,
      center: defaultCenter,
      size: defaultSize,
      rotation: 0.0,
    );
    
    _watermarkConfig = WatermarkConfig(
      enabled: true,
      type: WatermarkType.text,
      text: '@imagenarte',
      opacity: 0.35,
      color: const Color(0xFFFFFFFF),
      transform: defaultGeometry,
      locked: false,
      anchorPreset: WatermarkAnchorPreset.bottomRight,
      safeMargin: 0.03,
    );
    
    if (_activeTool == EditorTool.watermark) {
      _activeTransformTarget = TransformTarget.watermarkText;
    }
    
    pushUndo();
    notifyListeners();
  }

  /// Inicializa un watermark por defecto si no existe
  void initializeWatermarkIfNeeded(Size canvasSize) {
    if (_watermarkConfig == null) {
      resetWatermark(canvasSize);
    } else if (_activeTool == EditorTool.watermark && _watermarkConfig!.enabled) {
      // Asegurar que está seleccionado si la herramienta está activa
      _activeTransformTarget = _watermarkIsText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
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
      watermarkConfig: _watermarkConfig != null
          ? WatermarkConfig(
              enabled: _watermarkConfig!.enabled,
              type: _watermarkConfig!.type,
              text: _watermarkConfig!.text,
              imagePath: _watermarkConfig!.imagePath,
              opacity: _watermarkConfig!.opacity,
              color: _watermarkConfig!.color,
              outline: _watermarkConfig!.outline != null
                  ? WatermarkOutline(
                      enabled: _watermarkConfig!.outline!.enabled,
                      color: _watermarkConfig!.outline!.color,
                      width: _watermarkConfig!.outline!.width,
                    )
                  : null,
              shadow: _watermarkConfig!.shadow != null
                  ? WatermarkShadow(
                      enabled: _watermarkConfig!.shadow!.enabled,
                      blur: _watermarkConfig!.shadow!.blur,
                      offset: _watermarkConfig!.shadow!.offset,
                      color: _watermarkConfig!.shadow!.color,
                    )
                  : null,
              transform: TransformableGeometry(
                shape: _watermarkConfig!.transform.shape,
                center: _watermarkConfig!.transform.center,
                size: _watermarkConfig!.transform.size,
                rotation: _watermarkConfig!.transform.rotation,
              ),
              locked: _watermarkConfig!.locked,
              anchorPreset: _watermarkConfig!.anchorPreset,
              safeMargin: _watermarkConfig!.safeMargin,
            )
          : null,
      colorMode: _colorMode,
      colorIntensity: _colorIntensity,
      blurIntensity: _blurIntensity,
      brightness: _brightness,
      contrast: _contrast,
      saturation: _saturation,
      sharpness: _sharpness,
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
    _watermarkConfig = snapshot.watermarkConfig != null
        ? WatermarkConfig(
            enabled: snapshot.watermarkConfig!.enabled,
            type: snapshot.watermarkConfig!.type,
            text: snapshot.watermarkConfig!.text,
            imagePath: snapshot.watermarkConfig!.imagePath,
            opacity: snapshot.watermarkConfig!.opacity,
            color: snapshot.watermarkConfig!.color,
            outline: snapshot.watermarkConfig!.outline != null
                ? WatermarkOutline(
                    enabled: snapshot.watermarkConfig!.outline!.enabled,
                    color: snapshot.watermarkConfig!.outline!.color,
                    width: snapshot.watermarkConfig!.outline!.width,
                  )
                : null,
            shadow: snapshot.watermarkConfig!.shadow != null
                ? WatermarkShadow(
                    enabled: snapshot.watermarkConfig!.shadow!.enabled,
                    blur: snapshot.watermarkConfig!.shadow!.blur,
                    offset: snapshot.watermarkConfig!.shadow!.offset,
                    color: snapshot.watermarkConfig!.shadow!.color,
                  )
                : null,
            transform: TransformableGeometry(
              shape: snapshot.watermarkConfig!.transform.shape,
              center: snapshot.watermarkConfig!.transform.center,
              size: snapshot.watermarkConfig!.transform.size,
              rotation: snapshot.watermarkConfig!.transform.rotation,
            ),
            locked: snapshot.watermarkConfig!.locked,
            anchorPreset: snapshot.watermarkConfig!.anchorPreset,
            safeMargin: snapshot.watermarkConfig!.safeMargin,
          )
        : null;
    _colorMode = snapshot.colorMode;
    _colorIntensity = snapshot.colorIntensity;
    _blurIntensity = snapshot.blurIntensity;
    _brightness = snapshot.brightness;
    _contrast = snapshot.contrast;
    _saturation = snapshot.saturation;
    _sharpness = snapshot.sharpness;
    _isPreviewingClassicAdjustments = false;
    _classicAdjustmentsThrottleTimer?.cancel();

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
  
  bool get isPreviewingClassicAdjustments => _isPreviewingClassicAdjustments;
  
  void setBrightness(double value) {
    _brightness = value.clamp(-100.0, 100.0);
    _isPreviewingClassicAdjustments = true;
    _schedulePreviewUpdate();
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    notifyListeners();
  }
  
  void setContrast(double value) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    _contrast = value.clamp(-100.0, 100.0);
    _isPreviewingClassicAdjustments = true;
    _schedulePreviewUpdate();
    notifyListeners();
  }
  
  void setSaturation(double value) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    _saturation = value.clamp(-100.0, 100.0);
    _isPreviewingClassicAdjustments = true;
    _schedulePreviewUpdate();
    notifyListeners();
  }
  
  void setSharpness(double value) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    _sharpness = value.clamp(0.0, 100.0);
    _isPreviewingClassicAdjustments = true;
    _schedulePreviewUpdate();
    notifyListeners();
  }
  
  /// Programa una actualización de preview con throttle
  void _schedulePreviewUpdate() {
    _classicAdjustmentsThrottleTimer?.cancel();
    _classicAdjustmentsThrottleTimer = Timer(_classicAdjustmentsThrottleDelay, () {
      // El preview se actualiza automáticamente cuando cambian los valores
      // Este timer solo asegura que no se actualice demasiado rápido
    });
  }
  
  /// Confirma los ajustes clásicos (onChangeEnd)
  /// Esto commitea los cambios y agrega un paso al undo
  void commitClassicAdjustments() {
    _isPreviewingClassicAdjustments = false;
    _classicAdjustmentsThrottleTimer?.cancel();
    pushUndo();
    notifyListeners();
  }
  
  /// Cancela el preview temporal y vuelve al estado base
  void cancelClassicAdjustmentsPreview() {
    _isPreviewingClassicAdjustments = false;
    _classicAdjustmentsThrottleTimer?.cancel();
    notifyListeners();
  }
  
  // Métodos para intensidades de efectos
  void setBlurIntensity(double value) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    _blurIntensity = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setPixelateIntensity(double value) {
    resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    _pixelateIntensity = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  // setWatermarkOpacity ya está implementado arriba

  void setMetadataRemovalEnabled(bool enabled) {
    _metadataRemovalEnabled = enabled;
    notifyListeners();
  }

  /// Actualiza la configuración de collage
  void setCollageConfig(CollageConfig config) {
    _collageConfig = config;
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

  /// Activa el modo zoom al tocar la lupa
  void onMagnifierTap() {
    // Cancelar timer anterior si existe
    _toolAutoCloseTimer?.cancel();
    _toolAutoCloseTimer = null;
    
    _zoomUiVisible = true;
    _zoomT = 0.0;
    _zoomScale = 1.0;
    _zoomOffset = Offset.zero;
    _toolHasBeenUsed = false; // Resetear flag para zoom
    setContext(EditorContext.zoom);
    
    // Iniciar timer de auto-cierre inicial (10 segundos si no se usa)
    _startToolAutoCloseTimer(isInitial: true);
    
    notifyListeners();
  }

  /// Actualiza el valor del dial de zoom
  /// t: valor en rango [-1.0 .. +1.0]
  void onZoomChanged(double t) {
    _zoomT = t.clamp(-1.0, 1.0);
    // Mapeo: scale = clamp(1 + t * 2.0, 0.5, 3.0)
    _zoomScale = (1.0 + _zoomT * 2.0).clamp(0.5, 3.0);
    // Reiniciar timer al interactuar con el zoom
    if (_zoomUiVisible) {
      _toolHasBeenUsed = true; // Marcar que el zoom ha sido usado
      _startToolAutoCloseTimer(isInitial: false); // Usar delay de 3 segundos
    }
    // También reiniciar si hay herramienta activa
    if (_activeTool != EditorTool.none && _activeTool != EditorTool.home) {
      resetToolAutoCloseTimer();
    }
    notifyListeners();
  }

  /// Actualiza el offset del zoom (pan)
  /// Limita el offset para que la imagen no se salga del área visible
  void updateZoomOffset(Offset delta, Size canvasSize, Size? imageSize) {
    // Reiniciar timer al interactuar con el zoom (pan)
    if (_zoomUiVisible) {
      _toolHasBeenUsed = true; // Marcar que el zoom ha sido usado
      _startToolAutoCloseTimer(isInitial: false); // Usar delay de 3 segundos
    }
    // También reiniciar si hay herramienta activa
    if (_activeTool != EditorTool.none && _activeTool != EditorTool.home) {
      resetToolAutoCloseTimer();
    }
    if (imageSize == null || _zoomScale <= 1.0) {
      _zoomOffset = Offset.zero;
      notifyListeners();
      return;
    }

    // Calcular el tamaño de la imagen escalada
    final imageAspect = imageSize.width / imageSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;
    
    double scaledWidth, scaledHeight;
    if (imageAspect > canvasAspect) {
      scaledWidth = canvasSize.width * _zoomScale;
      scaledHeight = scaledWidth / imageAspect;
    } else {
      scaledHeight = canvasSize.height * _zoomScale;
      scaledWidth = scaledHeight * imageAspect;
    }

    // Calcular límites del pan
    final maxOffsetX = (scaledWidth - canvasSize.width) / 2;
    final maxOffsetY = (scaledHeight - canvasSize.height) / 2;

    // Aplicar delta y limitar
    final newOffsetX = (_zoomOffset.dx + delta.dx).clamp(-maxOffsetX, maxOffsetX);
    final newOffsetY = (_zoomOffset.dy + delta.dy).clamp(-maxOffsetY, maxOffsetY);
    
    _zoomOffset = Offset(newOffsetX, newOffsetY);
    notifyListeners();
  }

  /// Resetea el zoom al valor neutro
  void onZoomReset() {
    _zoomT = 0.0;
    _zoomScale = 1.0;
    _zoomOffset = Offset.zero;
    // Reiniciar timer al interactuar con el zoom
    if (_zoomUiVisible) {
      _toolHasBeenUsed = true; // Marcar que el zoom ha sido usado
      _startToolAutoCloseTimer(isInitial: false); // Usar delay de 3 segundos
    }
    // También reiniciar si hay herramienta activa
    if (_activeTool != EditorTool.none && _activeTool != EditorTool.home) {
      resetToolAutoCloseTimer();
    }
    notifyListeners();
  }

  /// Oculta el UI de zoom (al cambiar de herramienta)
  void hideZoomUi() {
    if (_zoomUiVisible) {
      _toolAutoCloseTimer?.cancel();
      _toolAutoCloseTimer = null;
      _zoomUiVisible = false;
      _zoomT = 0.0;
      _zoomScale = 1.0;
      _zoomOffset = Offset.zero;
      _toolHasBeenUsed = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _selectionThrottleTimer?.cancel();
    _watermarkTransformDebounceTimer?.cancel();
    _toolAutoCloseTimer?.cancel();
    super.dispose();
  }
}

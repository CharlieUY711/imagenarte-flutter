import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:core/application/editor_controller.dart' show EditorController, EffectMode, ColorPreset;
import 'package:core/domain/roi.dart';
import 'package:core/domain/export_profile.dart';
import 'package:core/usecases/export_media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:processing/processing.dart';
import 'editor_controller_factory.dart';

/// Snapshot del estado del editor para el historial
/// 
/// Almacena una copia profunda del estado necesario para restaurar
/// el editor a un punto anterior.
class EditorStateSnapshot {
  final List<ROI> rois;
  final bool autoFaceEnabled;
  final EffectMode effectMode;
  final int effectIntensity;
  final String? selectedRoiId;
  final double brightness;
  final double contrast;
  final double saturation;
  final ColorPreset colorPreset;
  final Uint8List? imageBytes;
  final String? imagePath;
  final int? imageWidth;
  final int? imageHeight;

  EditorStateSnapshot({
    required this.rois,
    required this.autoFaceEnabled,
    required this.effectMode,
    required this.effectIntensity,
    this.selectedRoiId,
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.colorPreset = ColorPreset.color,
    this.imageBytes,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
  });

  /// Crea una copia profunda del snapshot
  EditorStateSnapshot copy() {
    // Deep copy de la lista de ROIs (ROI es inmutable, pero la lista no)
    final roisCopy = rois.map((roi) => roi.copyWith()).toList();
    
    // Deep copy de imageBytes si existe
    Uint8List? imageBytesCopy;
    if (imageBytes != null) {
      imageBytesCopy = Uint8List.fromList(imageBytes!);
    }

    return EditorStateSnapshot(
      rois: roisCopy,
      autoFaceEnabled: autoFaceEnabled,
      effectMode: effectMode,
      effectIntensity: effectIntensity,
      selectedRoiId: selectedRoiId,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
      colorPreset: colorPreset,
      imageBytes: imageBytesCopy,
      imagePath: imagePath,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }
}

/// ViewModel que adapta EditorController para la UI
/// 
/// Encapsula el EditorController y expone estado derivado para la UI.
/// Notifica cambios mediante ChangeNotifier.
class EditorViewModel extends ChangeNotifier {
  final EditorController _controller;
  final ExportMedia _exportMedia;

  // Estado derivado para UI
  bool _isBusy = false;
  String? _error;

  // Sistema de historial (Undo/Redo)
  // Mínimo 10 niveles según requerimiento del PRD
  // 10 niveles permite al usuario deshacer una secuencia razonable de operaciones
  // sin consumir demasiada memoria. Se implementa como FIFO: cuando se excede
  // el límite, se elimina el snapshot más antiguo.
  static const int _maxUndoLevels = 10; // Mínimo requerido: 10 niveles de undo
  
  final List<EditorStateSnapshot> _undoStack = [];
  final List<EditorStateSnapshot> _redoStack = [];

  EditorViewModel({
    required EditorController controller,
    required ExportMedia exportMedia,
  })  : _controller = controller,
        _exportMedia = exportMedia;

  // Getters de estado
  bool get autoFaceEnabled => _controller.autoFaceEnabled;
  List<ROI> get rois => _controller.rois;
  String? get selectedRoiId => _controller.selectedRoiId;
  ROI? get activeRoi => _controller.getActiveRoi();
  bool get hasActiveRoi => _controller.hasActiveRoi();
  double get brightness => _controller.brightness;
  double get contrast => _controller.contrast;
  double get saturation => _controller.saturation;
  ColorPreset get colorPreset => _controller.colorPreset;
  bool get isBusy => _isBusy;
  String? get error => _error;
  String? get imagePath => _controller.imagePath;
  Uint8List? get imageBytes => _controller.imageBytes;
  int? get imageWidth => _controller.imageWidth;
  int? get imageHeight => _controller.imageHeight;
  
  // Getters de historial
  bool get canUndo => _undoStack.isNotEmpty;
  int get undoCount => _undoStack.length;

  /// Guarda el estado actual en el historial ANTES de aplicar cambios
  /// 
  /// Este método debe llamarse antes de cualquier operación que mute el estado.
  void _commitToHistory() {
    // Crear snapshot del estado actual
    final snapshot = EditorStateSnapshot(
      rois: List.from(_controller.rois), // Copia de la lista
      autoFaceEnabled: _controller.autoFaceEnabled,
      effectMode: _controller.effectMode,
      effectIntensity: _controller.effectIntensity,
      selectedRoiId: _controller.selectedRoiId,
      brightness: _controller.brightness,
      contrast: _controller.contrast,
      saturation: _controller.saturation,
      colorPreset: _controller.colorPreset,
      imageBytes: _controller.imageBytes != null 
          ? Uint8List.fromList(_controller.imageBytes!) 
          : null,
      imagePath: _controller.imagePath,
      imageWidth: _controller.imageWidth,
      imageHeight: _controller.imageHeight,
    );

    // Agregar al stack de undo
    _undoStack.add(snapshot);

    // Limitar a _maxUndoLevels (FIFO: remover el más antiguo)
    if (_undoStack.length > _maxUndoLevels) {
      _undoStack.removeAt(0);
    }

    // Limpiar redo stack cuando se hace una acción nueva
    _redoStack.clear();
  }

  /// Restaura el estado desde un snapshot
  void _restoreFromSnapshot(EditorStateSnapshot snapshot) {
    // Restaurar estado completo usando el método del controller
    _controller.restoreState(
      rois: snapshot.rois,
      autoFaceEnabled: snapshot.autoFaceEnabled,
      effectMode: snapshot.effectMode,
      effectIntensity: snapshot.effectIntensity,
      selectedRoiId: snapshot.selectedRoiId,
      brightness: snapshot.brightness,
      contrast: snapshot.contrast,
      saturation: snapshot.saturation,
      colorPreset: snapshot.colorPreset,
    );
  }

  /// Deshace la última operación
  void undo() {
    if (!canUndo) return;

    // Guardar estado actual en redo stack antes de deshacer
    final currentSnapshot = EditorStateSnapshot(
      rois: List.from(_controller.rois),
      autoFaceEnabled: _controller.autoFaceEnabled,
      effectMode: _controller.effectMode,
      effectIntensity: _controller.effectIntensity,
      selectedRoiId: _controller.selectedRoiId,
      brightness: _controller.brightness,
      contrast: _controller.contrast,
      saturation: _controller.saturation,
      colorPreset: _controller.colorPreset,
      imageBytes: _controller.imageBytes != null 
          ? Uint8List.fromList(_controller.imageBytes!) 
          : null,
      imagePath: _controller.imagePath,
      imageWidth: _controller.imageWidth,
      imageHeight: _controller.imageHeight,
    );
    _redoStack.add(currentSnapshot);

    // Restaurar estado anterior
    final previousSnapshot = _undoStack.removeLast();
    _restoreFromSnapshot(previousSnapshot);
    
    notifyListeners();
  }

  /// Inicializa el editor con una imagen
  /// 
  /// Decodifica la imagen para obtener dimensiones y carga en el controller.
  Future<void> initWithImage({
    required Uint8List bytes,
    required int width,
    required int height,
  }) async {
    _setBusy(true);
    _clearError();

    try {
      await _controller.loadImageFromBytes(bytes);
      // Limpiar historial al cargar nueva imagen
      _undoStack.clear();
      _redoStack.clear();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar imagen: $e');
    } finally {
      _setBusy(false);
    }
  }

  /// Carga imagen desde un path
  Future<void> initWithImagePath(String imagePath) async {
    _setBusy(true);
    _clearError();

    try {
      await _controller.loadImage(imagePath);
      // Limpiar historial al cargar nueva imagen
      _undoStack.clear();
      _redoStack.clear();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar imagen: $e');
    } finally {
      _setBusy(false);
    }
  }

  /// Toggle de detección automática de rostro
  /// Si se activa, detecta automáticamente
  Future<void> toggleAutoFace(bool on) async {
    _setBusy(true);
    _clearError();

    try {
      _commitToHistory(); // Guardar estado antes de cambiar
      await _controller.toggleAutoFace(on);
      notifyListeners();
    } catch (e) {
      _setError('Error al cambiar auto-detección: $e');
    } finally {
      _setBusy(false);
    }
  }

  /// Re-detecta rostros (solo si auto-face está habilitado)
  Future<void> redetectFaces() async {
    if (!_controller.autoFaceEnabled) return;

    _setBusy(true);
    _clearError();

    try {
      _commitToHistory(); // Guardar estado antes de re-detectar
      await _controller.redetectFaces();
      notifyListeners();
    } catch (e) {
      _setError('Error al re-detectar rostros: $e');
    } finally {
      _setBusy(false);
    }
  }

  /// Agrega una ROI manual centrada en la imagen
  void addZone() {
    if (_controller.imageWidth == null || _controller.imageHeight == null) {
      _setError('No hay imagen cargada');
      return;
    }

    try {
      _commitToHistory(); // Guardar estado antes de agregar ROI
      // Crear ROI centrada (20% del tamaño de la imagen)
      final centerX = 0.5 - 0.1; // 0.4
      final centerY = 0.5 - 0.1; // 0.4
      final size = 0.2; // 20% del tamaño

      _controller.addManualRoi(
        shape: RoiShape.rect,
        x: centerX,
        y: centerY,
        width: size,
        height: size,
      );
      notifyListeners();
    } catch (e) {
      _setError('Error al agregar zona: $e');
    }
  }

  /// Actualiza una ROI existente
  void updateRoi(
    String id, {
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    try {
      _commitToHistory(); // Guardar estado antes de actualizar ROI
      _controller.updateRoi(
        id,
        x: x,
        y: y,
        width: width,
        height: height,
      );
      notifyListeners();
    } catch (e) {
      _setError('Error al actualizar ROI: $e');
    }
  }

  /// Elimina una ROI
  void deleteRoi(String id) {
    try {
      _commitToHistory(); // Guardar estado antes de eliminar ROI
      _controller.deleteRoi(id);
      // Si se eliminó la ROI activa, limpiar selección
      if (_controller.selectedRoiId == id) {
        _controller.setSelectedRoiId(null);
      }
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar ROI: $e');
    }
  }
  
  /// Establece la ROI seleccionada (activa)
  /// 
  /// NOTA: No hace commit al historial porque cambiar selección no es una operación
  /// que deba deshacerse. Solo cambia qué ROI está activa para aplicar herramientas.
  void setSelectedRoiId(String? roiId) {
    try {
      _controller.setSelectedRoiId(roiId);
      notifyListeners();
    } catch (e) {
      _setError('Error al seleccionar ROI: $e');
    }
  }
  
  /// Establece el brillo
  void setBrightness(double value) {
    _commitToHistory(); // Guardar estado antes de cambiar ajuste
    _controller.setBrightness(value);
    notifyListeners();
  }
  
  /// Establece el contraste
  void setContrast(double value) {
    _commitToHistory(); // Guardar estado antes de cambiar ajuste
    _controller.setContrast(value);
    notifyListeners();
  }
  
  /// Establece la saturación
  void setSaturation(double value) {
    _commitToHistory(); // Guardar estado antes de cambiar ajuste
    _controller.setSaturation(value);
    notifyListeners();
  }
  
  /// Establece el preset de color
  void setColorPreset(ColorPreset preset) {
    _commitToHistory(); // Guardar estado antes de cambiar preset
    _controller.setColorPreset(preset);
    notifyListeners();
  }
  
  /// Establece el modo de efecto (pixelate/blur)
  void setEffectMode(EffectMode mode) {
    _commitToHistory(); // Guardar estado antes de aplicar herramienta
    _controller.setEffectMode(mode);
    notifyListeners();
  }
  
  /// Establece la intensidad del efecto (1-10)
  void setEffectIntensity(int intensity) {
    _commitToHistory(); // Guardar estado antes de cambiar intensidad
    _controller.setEffectIntensity(intensity);
    notifyListeners();
  }
  
  /// Obtiene los bytes de la imagen procesada con ajustes aplicados
  /// 
  /// Usado para preview en tiempo real.
  /// Aplica ajustes según la regla: si hay ROI activa, solo a esa ROI; si no, globalmente.
  Future<Uint8List?> getProcessedImageBytes() async {
    if (_controller.imageBytes == null || 
        _controller.imageWidth == null || 
        _controller.imageHeight == null) {
      return null;
    }

    // Si no hay ajustes ni preset, retornar imagen original
    if (_controller.brightness == 0.0 && 
        _controller.contrast == 0.0 && 
        _controller.saturation == 0.0 && 
        _controller.colorPreset == ColorPreset.color) {
      return _controller.imageBytes;
    }

    try {
      final activeRoi = _controller.getActiveRoi();
      final adjustmentsProcessor = ImageAdjustmentsProcessor();
      
      return await adjustmentsProcessor.applyAdjustments(
        imageBytes: _controller.imageBytes!,
        brightness: _controller.brightness,
        contrast: _controller.contrast,
        saturation: _controller.saturation,
        colorPreset: _controller.colorPreset,
        roi: activeRoi,
        imageWidth: _controller.imageWidth!,
        imageHeight: _controller.imageHeight!,
      );
    } catch (e) {
      _setError('Error al procesar imagen: $e');
      return _controller.imageBytes; // Fallback a original
    }
  }

  /// Exporta la imagen con el perfil especificado
  /// 
  /// Aplica efectos en ROIs y exporta según el perfil.
  Future<String?> export(ExportProfile profile) async {
    if (_controller.imagePath == null && _controller.imageBytes == null) {
      _setError('No hay imagen para exportar');
      return null;
    }

    _setBusy(true);
    _clearError();

    try {
      // Obtener path de imagen (original o temporal)
      String sourceImagePath;
      if (_controller.imagePath != null) {
        sourceImagePath = _controller.imagePath!;
      } else {
        // Crear archivo temporal desde bytes
        final tempDir = await getTemporaryDirectory();
        final tempPath = path.join(tempDir.path, 'editor_temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await File(tempPath).writeAsBytes(_controller.imageBytes!);
        sourceImagePath = tempPath;
      }

      // Generar path de salida
      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = profile.format.toLowerCase();
      final outputPath = path.join(
        outputDir.path,
        'imagenarte_export_$timestamp.$extension',
      );

      // Procesar imagen: primero ajustes, luego ROIs
      String processedImagePath = sourceImagePath;
      
      // 1. Aplicar ajustes (brightness, contrast, saturation, color preset)
      // Si hay ROI activa, aplicar solo a esa ROI; si no, aplicar globalmente
      final activeRoi = _controller.getActiveRoi();
      final adjustmentsProcessor = ImageAdjustmentsProcessor();
      
      final imageBytesForAdjustments = await File(processedImagePath).readAsBytes();
      final adjustedBytes = await adjustmentsProcessor.applyAdjustments(
        imageBytes: imageBytesForAdjustments,
        brightness: _controller.brightness,
        contrast: _controller.contrast,
        saturation: _controller.saturation,
        colorPreset: _controller.colorPreset,
        roi: activeRoi,
        imageWidth: _controller.imageWidth!,
        imageHeight: _controller.imageHeight!,
      );
      
      // Guardar imagen con ajustes aplicados
      final tempDir = await getTemporaryDirectory();
      final adjustedPath = path.join(
        tempDir.path,
        'editor_adjusted_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(adjustedPath).writeAsBytes(adjustedBytes);
      processedImagePath = adjustedPath;
      
      // 2. Procesar ROIs (pixelate/blur) 
      // REGLA: Si hay ROI activa, aplicar SOLO a esa ROI; si no, aplicar a todas las ROIs
      final roisToProcess = activeRoi != null ? [activeRoi] : _controller.rois;
      
      if (roisToProcess.isNotEmpty) {
        processedImagePath = await EditorControllerFactory.processRois(
          imagePath: processedImagePath,
          rois: roisToProcess,
          effectMode: _controller.effectMode,
          effectIntensity: _controller.effectIntensity,
        );
      }

      // Exportar usando ExportMedia (sin operations, ya procesamos ROIs)
      final exportedPath = await _exportMedia.execute(
        imagePath: processedImagePath,
        outputPath: outputPath,
        profile: profile,
        operations: const [], // Ya procesamos ROIs arriba
      );

      notifyListeners();
      return exportedPath;
    } catch (e) {
      _setError('Error al exportar: $e');
      return null;
    } finally {
      _setBusy(false);
    }
  }

  // Helpers privados
  void _setBusy(bool value) {
    if (_isBusy != value) {
      _isBusy = value;
      notifyListeners();
    }
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

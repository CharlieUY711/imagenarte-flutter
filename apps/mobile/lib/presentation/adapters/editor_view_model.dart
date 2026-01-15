import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:core/application/editor_controller.dart';
import 'package:core/domain/roi.dart';
import 'package:core/domain/export_profile.dart';
import 'package:core/usecases/export_media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'editor_controller_factory.dart';

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

  EditorViewModel({
    required EditorController controller,
    required ExportMedia exportMedia,
  })  : _controller = controller,
        _exportMedia = exportMedia;

  // Getters de estado
  bool get autoFaceEnabled => _controller.autoFaceEnabled;
  List<ROI> get rois => _controller.rois;
  bool get isBusy => _isBusy;
  String? get error => _error;
  String? get imagePath => _controller.imagePath;
  Uint8List? get imageBytes => _controller.imageBytes;
  int? get imageWidth => _controller.imageWidth;
  int? get imageHeight => _controller.imageHeight;

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
      _controller.deleteRoi(id);
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar ROI: $e');
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

      // Procesar ROIs antes de exportar (si hay ROIs)
      String processedImagePath = sourceImagePath;
      if (_controller.rois.isNotEmpty) {
        processedImagePath = await EditorControllerFactory.processRois(
          imagePath: sourceImagePath,
          rois: _controller.rois,
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

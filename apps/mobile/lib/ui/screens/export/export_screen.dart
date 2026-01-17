import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import '../../widgets/platform_image.dart';
import '../../utils/file_helper.dart';
import 'package:core/domain/export_profile.dart';
import 'package:core/domain/operation.dart';
import 'package:core/domain/roi.dart';
import 'package:core/application/editor_controller.dart';
import 'package:core/usecases/export_media.dart';
import 'package:core/privacy/temp_cleanup.dart';
import 'package:core/privacy/exif_sanitizer.dart';
import 'package:watermark/visible/visible_watermark.dart';
import 'package:watermark/invisible/invisible_watermark.dart';
import 'package:processing/infrastructure/imaging/roi_image_processor.dart';

class ExportScreen extends StatefulWidget {
  final String? imagePath;
  final List<Operation> operations;
  final List<ROI>? rois;
  final EffectMode? effectMode;
  final int? effectIntensity;

  const ExportScreen({
    super.key,
    this.imagePath,
    required this.operations,
    this.rois,
    this.effectMode,
    this.effectIntensity,
  });

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _processedImagePath;
  Uint8List? _processedImageBytes;
  Uint8List? _originalImageBytes;
  bool _isProcessing = false;
  bool _isExporting = false;

  // Configuración de exportación
  String _format = 'jpg';
  int _quality = 85;
  bool _sanitizeMetadata = true;
  bool _visibleWatermark = false;
  String? _visibleWatermarkText;
  bool _invisibleWatermark = false; // Default OFF para MVP (puede cambiarse a true)
  bool _exportManifest = false;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (widget.imagePath == null) return;

    setState(() => _isProcessing = true);

    try {
      final imageBytes = await FileHelper.readFileAsBytes(widget.imagePath!);
      _originalImageBytes = imageBytes;
      
      // Si hay ROIs, procesar con RoiImageProcessor
      if (widget.rois != null && widget.rois!.isNotEmpty && widget.effectMode != null) {
        final processor = RoiImageProcessor();
        Uint8List processedBytes;
        
        switch (widget.effectMode!) {
          case EffectMode.pixelate:
            processedBytes = await processor.applyPixelateToRois(
              imageBytes: imageBytes,
              rois: widget.rois!,
              intensity: widget.effectIntensity ?? 5,
            );
            break;
          case EffectMode.blur:
            processedBytes = await processor.applyBlurToRois(
              imageBytes: imageBytes,
              rois: widget.rois!,
              intensity: widget.effectIntensity ?? 5,
            );
            break;
        }
        
        // Guardar temporal procesado
        final tempDir = FileHelper.getSystemTempPath();
        final tempPath = path.join(tempDir, 'processed_${DateTime.now().millisecondsSinceEpoch}.png');
        await FileHelper.writeFileAsBytes(tempPath, processedBytes);
        
        setState(() {
          _processedImagePath = tempPath;
          _processedImageBytes = processedBytes;
          _isProcessing = false;
        });
      } else {
        // Sin ROIs, usar imagen original
        setState(() {
          _processedImagePath = widget.imagePath;
          _processedImageBytes = imageBytes;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar: $e')),
        );
      }
    }
  }

  Future<void> _exportImage() async {
    if (_processedImagePath == null) return;

    setState(() => _isExporting = true);

    try {
      // Obtener directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = path.join(
        directory.path,
        'imagenarte_export_$timestamp.$_format',
      );

      // Crear perfil de exportación
      final profile = ExportProfile(
        format: _format,
        quality: _quality,
        sanitizeMetadata: _sanitizeMetadata,
        visibleWatermark: _visibleWatermark,
        visibleWatermarkText: _visibleWatermarkText,
        invisibleWatermark: _invisibleWatermark,
        exportManifest: _exportManifest,
      );

      // Exportar
      final exportMedia = ExportMedia(
        ExifSanitizer(),
        VisibleWatermark(),
        InvisibleWatermark(),
      );

      final exportedPath = await exportMedia.execute(
        imagePath: _processedImagePath!,
        outputPath: outputPath,
        profile: profile,
        operations: widget.operations,
      );

      // Limpiar temporales
      final tempFiles = <String>[];
      if (widget.imagePath != null) tempFiles.add(widget.imagePath!);
      if (_processedImagePath != null) tempFiles.add(_processedImagePath!);
      await TempCleanup.deleteFiles(tempFiles);

      setState(() => _isExporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen exportada: ${path.basename(exportedPath)}'),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_processedImagePath != null)
              PlatformImage(
                imagePath: _processedImagePath,
                imageBytes: _processedImageBytes,
                height: 300,
                fit: BoxFit.contain,
              )
            else if (widget.imagePath != null)
              PlatformImage(
                imagePath: widget.imagePath,
                imageBytes: _originalImageBytes,
                height: 300,
                fit: BoxFit.contain,
              ),

            const SizedBox(height: 24),

            // Formato y calidad
            const Text(
              'Formato y Calidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _format,
              items: const [
                DropdownMenuItem(value: 'jpg', child: Text('JPG')),
                DropdownMenuItem(value: 'png', child: Text('PNG')),
                DropdownMenuItem(value: 'webp', child: Text('WebP')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _format = value);
                }
              },
            ),
            const SizedBox(height: 8),
            Text('Calidad: $_quality'),
            Slider(
              value: _quality.toDouble(),
              min: 50,
              max: 100,
              divisions: 10,
              onChanged: (value) {
                setState(() => _quality = value.round());
              },
            ),

            const SizedBox(height: 24),

            // Privacidad
            const Text(
              'Privacidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Limpiar Metadatos (EXIF)'),
              subtitle: const Text('Recomendado: elimina información personal'),
              value: _sanitizeMetadata,
              onChanged: (value) {
                setState(() => _sanitizeMetadata = value);
              },
            ),

            const SizedBox(height: 24),

            // Watermarks
            const Text(
              'Watermarks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Watermark Visible'),
              value: _visibleWatermark,
              onChanged: (value) {
                setState(() => _visibleWatermark = value);
              },
            ),
            if (_visibleWatermark)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Texto del watermark',
                    hintText: 'Ej: @mi_usuario',
                  ),
                  onChanged: (value) {
                    setState(() => _visibleWatermarkText = value);
                  },
                ),
              ),
            SwitchListTile(
              title: const Text('Watermark Invisible (básico)'),
              subtitle: const Text('Token HMAC embebido en imagen (LSB)'),
              value: _invisibleWatermark,
              onChanged: (value) {
                setState(() => _invisibleWatermark = value);
              },
            ),
            if (_invisibleWatermark)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: SwitchListTile(
                  title: const Text('Exportar Comprobante'),
                  subtitle: const Text('Guardar manifest.json para verificación'),
                  value: _exportManifest,
                  onChanged: (value) {
                    setState(() => _exportManifest = value);
                  },
                ),
              ),

            const SizedBox(height: 32),

            // Botón exportar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isProcessing || _isExporting) ? null : _exportImage,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isExporting ? 'Exportando...' : 'Exportar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:core/domain/video_session.dart';
import 'package:core/domain/video_operation.dart';
import 'package:core/domain/tracking_region.dart';
import 'package:processing/engines/video/frame_extractor_engine.dart';
import 'package:processing/engines/video/face_detection_engine.dart';
import 'package:processing/engines/video/tracker_engine.dart';
import 'package:processing/engines/video/renderer_engine.dart';
import 'package:processing/ops/video/pixelate_face_video_op.dart';
import 'package:processing/ops/video/blur_region_video_op.dart';
import 'package:processing/ops/video/dynamic_watermark_video_op.dart';

/// Pipeline principal de procesamiento de video
/// 
/// Orquesta la extracción de frames, detección, tracking y render
class VideoPipeline {
  final FrameExtractorEngine _frameExtractor;
  final FaceDetectionEngine _faceDetection;
  final TrackerEngine _tracker;
  final RendererEngine _renderer;
  final PixelateFaceVideoOp _pixelateFaceOp;
  final BlurRegionVideoOp _blurRegionOp;
  final DynamicWatermarkVideoOp _watermarkOp;

  VideoPipeline(
    this._frameExtractor,
    this._faceDetection,
    this._tracker,
    this._renderer,
    this._pixelateFaceOp,
    this._blurRegionOp,
    this._watermarkOp,
  );

  /// Procesa un video y genera un plan de procesamiento
  /// 
  /// En esta iteración (V0) solo genera el plan, no renderiza el video final
  Future<ProcessingPlan> processVideo({
    required VideoSession session,
    String? tempDir,
  }) async {
    if (session.inputUri == null) {
      throw ArgumentError('VideoSession debe tener inputUri');
    }

    final videoPath = session.inputUri!;
    final videoInfo = await _frameExtractor.extractVideoInfo(videoPath);
    if (videoInfo == null) {
      throw Exception('No se pudo extraer información del video');
    }

    var currentTrackingState = Map<String, TrackingRegion>.from(
      session.trackingState,
    );

    final processedFrames = <int, String>{};
    final tempFramesDir = tempDir ?? Directory.systemTemp.path;

    // Iterar sobre frames y procesar
    await _frameExtractor.iterateFrames(
      videoPath,
      (framePath, frameIndex) async {
        // Detección facial (stub por ahora)
        final detections = await _faceDetection.detectFaces(framePath);

        // Tracking: asociar detecciones con regiones existentes
        currentTrackingState = _tracker.associateDetections(
          frameIndex: frameIndex,
          detections: detections,
          existingRegions: currentTrackingState,
        );

        // Aplicar operaciones (stub por ahora)
        String? processedFramePath = framePath;
        for (final operation in session.operations) {
          if (!operation.enabled) continue;

          switch (operation.type) {
            case VideoOperationType.pixelateFace:
              // Buscar región de rostro para esta operación
              TrackingRegion? faceRegion;
              final faceRegions = currentTrackingState.values
                  .where((r) => r.type == TrackingRegionType.faceAuto)
                  .toList();
              if (faceRegions.isNotEmpty) {
                faceRegion = faceRegions.first;
              }
              final result = await _pixelateFaceOp.applyToFrame(
                framePath: processedFramePath!,
                frameIndex: frameIndex,
                operation: operation,
                region: faceRegion,
              );
              if (result != null) processedFramePath = result;
              break;

            case VideoOperationType.blurRegion:
              // Buscar región manual para esta operación
              final regionId = operation.params['region_id'] as String?;
              if (regionId != null && currentTrackingState.containsKey(regionId)) {
                final result = await _blurRegionOp.applyToFrame(
                  framePath: processedFramePath!,
                  frameIndex: frameIndex,
                  operation: operation,
                  region: currentTrackingState[regionId]!,
                );
                if (result != null) processedFramePath = result;
              }
              break;

            case VideoOperationType.dynamicWatermark:
              final result = await _watermarkOp.applyToFrame(
                framePath: processedFramePath!,
                frameIndex: frameIndex,
                operation: operation,
                sessionId: session.sessionId,
              );
              if (result != null) processedFramePath = result;
              break;
          }
        }

        if (processedFramePath != null) {
          processedFrames[frameIndex] = processedFramePath;
        }
      },
    );

    // Actualizar sesión con tracking state
    final updatedSession = session.copyWith(
      trackingState: currentTrackingState,
    );

    // Generar plan de procesamiento
    return ProcessingPlan(
      session: updatedSession,
      videoInfo: videoInfo,
      processedFrames: processedFrames,
    );
  }

  /// Guarda el plan de procesamiento como JSON temporal
  /// 
  /// Retorna la ruta del archivo JSON guardado
  Future<String> saveProcessingPlan(
    ProcessingPlan plan,
    String tempDir,
  ) async {
    final planJson = {
      'session': plan.session.toProcessingPlan(),
      'video_info': {
        'total_frames': plan.videoInfo.totalFrames,
        'fps': plan.videoInfo.fps,
        'width': plan.videoInfo.width,
        'height': plan.videoInfo.height,
        'duration_ms': plan.videoInfo.duration.inMilliseconds,
      },
      'processed_frames_count': plan.processedFrames.length,
    };

    final planPath = '$tempDir/processing_plan_${plan.session.sessionId}.json';
    await File(planPath).writeAsString(
      jsonEncode(planJson),
      encoding: utf8,
    );

    return planPath;
  }

  /// Carga un plan de procesamiento desde JSON
  static Future<ProcessingPlan> loadProcessingPlan(String planPath) async {
    final content = await File(planPath).readAsString(encoding: utf8);
    final json = jsonDecode(content) as Map<String, dynamic>;

    final session = VideoSession.fromProcessingPlan(
      json['session'] as Map<String, dynamic>,
    );

    final videoInfoJson = json['video_info'] as Map<String, dynamic>;
    final videoInfo = VideoInfo(
      totalFrames: videoInfoJson['total_frames'] as int,
      fps: (videoInfoJson['fps'] as num).toDouble(),
      width: videoInfoJson['width'] as int,
      height: videoInfoJson['height'] as int,
      duration: Duration(
        milliseconds: videoInfoJson['duration_ms'] as int,
      ),
    );

    final processedFramesJson =
        json['processed_frames'] as Map<String, dynamic>?;
    final processedFrames = processedFramesJson?.map(
          (k, v) => MapEntry(int.parse(k), v as String),
        ) ??
        {};

    return ProcessingPlan(
      session: session,
      videoInfo: videoInfo,
      processedFrames: processedFrames,
    );
  }
}

/// Plan de procesamiento generado por el pipeline
class ProcessingPlan {
  final VideoSession session;
  final VideoInfo videoInfo;
  final Map<int, String> processedFrames; // frameIndex -> framePath

  ProcessingPlan({
    required this.session,
    required this.videoInfo,
    required this.processedFrames,
  });
}

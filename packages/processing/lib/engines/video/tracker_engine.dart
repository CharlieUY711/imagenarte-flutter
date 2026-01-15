import 'package:core/domain/tracking_region.dart';

/// Engine para tracking de regiones a través de frames
/// 
/// Asocia bounding boxes a través de frames usando IOU + smoothing
abstract class TrackerEngine {
  /// Asocia un nuevo conjunto de detecciones con regiones existentes
  /// 
  /// Retorna las regiones actualizadas
  Map<String, TrackingRegion> associateDetections({
    required int frameIndex,
    required List<BoundingBox> detections,
    required Map<String, TrackingRegion> existingRegions,
    double iouThreshold = 0.3,
  });
}

/// Implementación simple usando IOU
class SimpleTrackerEngine implements TrackerEngine {
  @override
  Map<String, TrackingRegion> associateDetections({
    required int frameIndex,
    required List<BoundingBox> detections,
    required Map<String, TrackingRegion> existingRegions,
    double iouThreshold = 0.3,
  }) {
    final updatedRegions = Map<String, TrackingRegion>.from(existingRegions);
    final usedDetections = <int>{};

    // Intentar asociar cada región existente con una detección
    for (final entry in updatedRegions.entries) {
      final region = entry.value;
      final prevBox = region.getBoundingBoxAtFrame(frameIndex - 1);

      if (prevBox == null) continue;

      double bestIou = 0.0;
      int? bestDetectionIndex;

      for (int i = 0; i < detections.length; i++) {
        if (usedDetections.contains(i)) continue;

        final iou = prevBox.iou(detections[i]);
        if (iou > bestIou && iou >= iouThreshold) {
          bestIou = iou;
          bestDetectionIndex = i;
        }
      }

      if (bestDetectionIndex != null) {
        usedDetections.add(bestDetectionIndex);
        final updatedRegion = TrackingRegion(
          id: region.id,
          type: region.type,
          smoothing: region.smoothing,
          frameStates: Map<int, BoundingBox>.from(region.frameStates),
        );
        updatedRegion.updateFrame(frameIndex, detections[bestDetectionIndex]);
        updatedRegions[entry.key] = updatedRegion;
      }
    }

    // Crear nuevas regiones para detecciones no asociadas
    for (int i = 0; i < detections.length; i++) {
      if (!usedDetections.contains(i)) {
        final newRegionId = 'region_${updatedRegions.length}';
        final newRegion = TrackingRegion(
          id: newRegionId,
          type: TrackingRegionType.faceAuto,
        );
        newRegion.updateFrame(frameIndex, detections[i]);
        updatedRegions[newRegionId] = newRegion;
      }
    }

    return updatedRegions;
  }
}

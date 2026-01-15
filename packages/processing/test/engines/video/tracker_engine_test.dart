import 'package:test/test.dart';
import 'package:processing/engines/video/tracker_engine.dart';
import 'package:core/domain/tracking_region.dart';

void main() {
  group('SimpleTrackerEngine', () {
    late SimpleTrackerEngine tracker;

    setUp(() {
      tracker = SimpleTrackerEngine();
    });

    test('asocia detecciones con regiones existentes usando IOU', () {
      // Crear una región existente en el frame 0
      final existingRegion = TrackingRegion(
        id: 'region_0',
        type: TrackingRegionType.faceAuto,
      );
      existingRegion.updateFrame(0, BoundingBox(x: 100, y: 100, width: 50, height: 50));

      final existingRegions = {'region_0': existingRegion};

      // Nueva detección en frame 1 que se superpone (alto IOU)
      final newDetection = BoundingBox(x: 105, y: 105, width: 50, height: 50);

      final result = tracker.associateDetections(
        frameIndex: 1,
        detections: [newDetection],
        existingRegions: existingRegions,
        iouThreshold: 0.3,
      );

      expect(result.containsKey('region_0'), isTrue);
      final updatedRegion = result['region_0']!;
      expect(updatedRegion.frameStates.containsKey(1), isTrue);
      final boxAtFrame1 = updatedRegion.getBoundingBoxAtFrame(1);
      expect(boxAtFrame1, isNotNull);
      expect(boxAtFrame1!.x, closeTo(105, 5)); // Con smoothing puede variar
    });

    test('crea nuevas regiones para detecciones no asociadas', () {
      final existingRegions = <String, TrackingRegion>{};

      final newDetection = BoundingBox(x: 200, y: 200, width: 60, height: 60);

      final result = tracker.associateDetections(
        frameIndex: 0,
        detections: [newDetection],
        existingRegions: existingRegions,
        iouThreshold: 0.3,
      );

      expect(result.length, equals(1));
      expect(result.values.first.type, equals(TrackingRegionType.faceAuto));
      expect(result.values.first.frameStates.containsKey(0), isTrue);
    });

    test('no asocia detecciones con IOU muy bajo', () {
      final existingRegion = TrackingRegion(
        id: 'region_0',
        type: TrackingRegionType.faceAuto,
      );
      existingRegion.updateFrame(0, BoundingBox(x: 100, y: 100, width: 50, height: 50));

      final existingRegions = {'region_0': existingRegion};

      // Detección muy lejos (IOU bajo)
      final farDetection = BoundingBox(x: 500, y: 500, width: 50, height: 50);

      final result = tracker.associateDetections(
        frameIndex: 1,
        detections: [farDetection],
        existingRegions: existingRegions,
        iouThreshold: 0.3,
      );

      // Debe crear una nueva región en lugar de asociar
      expect(result.length, equals(2)); // region_0 + nueva región
      expect(result['region_0']!.frameStates.containsKey(1), isFalse);
    });

    test('maneja múltiples detecciones y regiones', () {
      final region1 = TrackingRegion(
        id: 'region_1',
        type: TrackingRegionType.faceAuto,
      );
      region1.updateFrame(0, BoundingBox(x: 100, y: 100, width: 50, height: 50));

      final region2 = TrackingRegion(
        id: 'region_2',
        type: TrackingRegionType.faceAuto,
      );
      region2.updateFrame(0, BoundingBox(x: 300, y: 300, width: 50, height: 50));

      final existingRegions = {'region_1': region1, 'region_2': region2};

      // Dos detecciones: una cerca de region_1, otra cerca de region_2
      final detection1 = BoundingBox(x: 105, y: 105, width: 50, height: 50);
      final detection2 = BoundingBox(x: 305, y: 305, width: 50, height: 50);

      final result = tracker.associateDetections(
        frameIndex: 1,
        detections: [detection1, detection2],
        existingRegions: existingRegions,
        iouThreshold: 0.3,
      );

      expect(result.length, equals(2));
      expect(result['region_1']!.frameStates.containsKey(1), isTrue);
      expect(result['region_2']!.frameStates.containsKey(1), isTrue);
    });
  });

  group('BoundingBox IOU', () {
    test('calcula IOU correctamente para boxes superpuestos', () {
      final box1 = BoundingBox(x: 0, y: 0, width: 100, height: 100);
      final box2 = BoundingBox(x: 50, y: 50, width: 100, height: 100);

      // Intersección: 50x50 = 2500
      // Unión: 10000 + 10000 - 2500 = 17500
      // IOU: 2500 / 17500 ≈ 0.143
      final iou = box1.iou(box2);
      expect(iou, closeTo(0.143, 0.01));
    });

    test('IOU es 0 para boxes no superpuestos', () {
      final box1 = BoundingBox(x: 0, y: 0, width: 100, height: 100);
      final box2 = BoundingBox(x: 200, y: 200, width: 100, height: 100);

      final iou = box1.iou(box2);
      expect(iou, equals(0.0));
    });

    test('IOU es 1.0 para boxes idénticos', () {
      final box1 = BoundingBox(x: 100, y: 100, width: 50, height: 50);
      final box2 = BoundingBox(x: 100, y: 100, width: 50, height: 50);

      final iou = box1.iou(box2);
      expect(iou, equals(1.0));
    });
  });
}

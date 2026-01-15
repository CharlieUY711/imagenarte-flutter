/// Tipo de región de tracking
enum TrackingRegionType {
  faceAuto, // Detección automática de rostro
  manualRect, // Rectángulo manual
}

/// Representa una región que se trackea a través de frames
class TrackingRegion {
  final String id;
  final TrackingRegionType type;
  final Map<int, BoundingBox> frameStates; // Estado por frame (keyframe simple)
  final double smoothing; // Factor de suavizado (0.0 - 1.0)

  TrackingRegion({
    required this.id,
    required this.type,
    Map<int, BoundingBox>? frameStates,
    this.smoothing = 0.3,
  }) : frameStates = frameStates ?? {};

  /// Obtiene el bounding box para un frame específico
  /// Interpola entre keyframes si es necesario
  BoundingBox? getBoundingBoxAtFrame(int frameIndex) {
    if (frameStates.isEmpty) return null;

    // Si hay un keyframe exacto, devolverlo
    if (frameStates.containsKey(frameIndex)) {
      return frameStates[frameIndex];
    }

    // Encontrar keyframes más cercanos
    final sortedFrames = frameStates.keys.toList()..sort();
    if (frameIndex < sortedFrames.first) {
      return frameStates[sortedFrames.first];
    }
    if (frameIndex > sortedFrames.last) {
      return frameStates[sortedFrames.last];
    }

    // Interpolar entre dos keyframes
    int? prevFrame;
    int? nextFrame;
    for (int i = 0; i < sortedFrames.length - 1; i++) {
      if (sortedFrames[i] <= frameIndex && sortedFrames[i + 1] >= frameIndex) {
        prevFrame = sortedFrames[i];
        nextFrame = sortedFrames[i + 1];
        break;
      }
    }

    if (prevFrame == null || nextFrame == null) {
      return frameStates[sortedFrames.first];
    }

    final prevBox = frameStates[prevFrame]!;
    final nextBox = frameStates[nextFrame]!;
    final t = (frameIndex - prevFrame) / (nextFrame - prevFrame);

    return BoundingBox(
      x: (prevBox.x + (nextBox.x - prevBox.x) * t).round(),
      y: (prevBox.y + (nextBox.y - prevBox.y) * t).round(),
      width: (prevBox.width + (nextBox.width - prevBox.width) * t).round(),
      height: (prevBox.height + (nextBox.height - prevBox.height) * t).round(),
    );
  }

  /// Actualiza el estado de un frame
  void updateFrame(int frameIndex, BoundingBox box) {
    // Aplicar smoothing si hay un estado previo
    if (frameStates.isNotEmpty && smoothing > 0) {
      final prevFrame = frameStates.keys
          .where((f) => f < frameIndex)
          .reduce((a, b) => a > b ? a : b);
      final prevBox = frameStates[prevFrame];
      if (prevBox != null) {
        frameStates[frameIndex] = BoundingBox(
          x: (prevBox.x * (1 - smoothing) + box.x * smoothing).round(),
          y: (prevBox.y * (1 - smoothing) + box.y * smoothing).round(),
          width: (prevBox.width * (1 - smoothing) + box.width * smoothing)
              .round(),
          height: (prevBox.height * (1 - smoothing) + box.height * smoothing)
              .round(),
        );
        return;
      }
    }
    frameStates[frameIndex] = box;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'smoothing': smoothing,
      'frame_states': frameStates.map(
        (frame, box) => MapEntry(
          frame.toString(),
          {
            'x': box.x,
            'y': box.y,
            'width': box.width,
            'height': box.height,
          },
        ),
      ),
    };
  }

  static TrackingRegion fromMap(Map<String, dynamic> map) {
    return TrackingRegion(
      id: map['id'] as String,
      type: TrackingRegionType.values.firstWhere(
        (t) => t.name == map['type'],
      ),
      smoothing: (map['smoothing'] as num?)?.toDouble() ?? 0.3,
      frameStates: (map['frame_states'] as Map<String, dynamic>?)?.map(
            (frameStr, boxMap) {
              final box = boxMap as Map<String, dynamic>;
              return MapEntry(
                int.parse(frameStr),
                BoundingBox(
                  x: box['x'] as int,
                  y: box['y'] as int,
                  width: box['width'] as int,
                  height: box['height'] as int,
                ),
              );
            },
          ) ??
          {},
    );
  }
}

/// Bounding box (rectángulo)
class BoundingBox {
  final int x;
  final int y;
  final int width;
  final int height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Calcula el área del bounding box
  int get area => width * height;

  /// Calcula el centro del bounding box
  Point get center => Point(x + width ~/ 2, y + height ~/ 2);

  /// Calcula la intersección sobre unión (IOU) con otro bounding box
  double iou(BoundingBox other) {
    final x1 = x > other.x ? x : other.x;
    final y1 = y > other.y ? y : other.y;
    final x2 = (x + width) < (other.x + other.width)
        ? (x + width)
        : (other.x + other.width);
    final y2 = (y + height) < (other.y + other.height)
        ? (y + height)
        : (other.y + other.height);

    if (x2 <= x1 || y2 <= y1) return 0.0;

    final intersection = (x2 - x1) * (y2 - y1);
    final union = area + other.area - intersection;

    return union > 0 ? intersection / union : 0.0;
  }
}

/// Punto 2D
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);
}

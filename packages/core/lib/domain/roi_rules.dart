import 'roi.dart';

/// Reglas de negocio para manejo de ROIs
class RoiRules {
  /// Calcula el Intersection over Union (IOU) entre dos ROIs
  /// 
  /// Retorna un valor entre 0.0 (sin overlap) y 1.0 (overlap completo)
  static double calculateIOU(ROI roi1, ROI roi2) {
    // Calcular intersección
    final x1 = roi1.x;
    final y1 = roi1.y;
    final x2 = roi1.x + roi1.width;
    final y2 = roi1.y + roi1.height;

    final x3 = roi2.x;
    final y3 = roi2.y;
    final x4 = roi2.x + roi2.width;
    final y4 = roi2.y + roi2.height;

    final intersectionX1 = x1 > x3 ? x1 : x3;
    final intersectionY1 = y1 > y3 ? y1 : y3;
    final intersectionX2 = x2 < x4 ? x2 : x4;
    final intersectionY2 = y2 < y4 ? y2 : y4;

    if (intersectionX2 <= intersectionX1 || intersectionY2 <= intersectionY1) {
      return 0.0; // Sin intersección
    }

    final intersectionArea = (intersectionX2 - intersectionX1) * (intersectionY2 - intersectionY1);
    final area1 = roi1.area;
    final area2 = roi2.area;
    final unionArea = area1 + area2 - intersectionArea;

    if (unionArea <= 0) return 0.0;

    return intersectionArea / unionArea;
  }

  /// Verifica si dos ROIs tienen overlap significativo
  /// 
  /// [threshold] es el IOU mínimo para considerar overlap (por defecto 0.3)
  static bool hasSignificantOverlap(ROI roi1, ROI roi2, {double threshold = 0.3}) {
    return calculateIOU(roi1, roi2) >= threshold;
  }

  /// Filtra ROIs automáticas que colisionan con ROIs manuales
  /// 
  /// Regla: Si una ROI auto colisiona con una ROI manual, se ignora la auto.
  static List<ROI> filterAutoRoisCollidingWithManual({
    required List<ROI> autoRois,
    required List<ROI> manualRois,
    double overlapThreshold = 0.3,
  }) {
    if (manualRois.isEmpty) return autoRois;

    return autoRois.where((autoRoi) {
      // Si la ROI auto está locked, mantenerla
      if (autoRoi.locked) return true;

      // Verificar colisión con cualquier ROI manual
      for (final manualRoi in manualRois) {
        if (hasSignificantOverlap(autoRoi, manualRoi, threshold: overlapThreshold)) {
          return false; // Colisiona, ignorar esta ROI auto
        }
      }
      return true; // No colisiona, mantener
    }).toList();
  }

  /// Combina ROIs automáticas y manuales aplicando reglas de negocio
  /// 
  /// Reglas:
  /// 1. ROIs manuales siempre se mantienen
  /// 2. ROIs automáticas locked se mantienen
  /// 3. ROIs automáticas que colisionan con manuales se ignoran
  /// 4. ROIs automáticas que colisionan entre sí se mantienen todas (el usuario puede decidir)
  static List<ROI> mergeRois({
    required List<ROI> autoRois,
    required List<ROI> manualRois,
    double overlapThreshold = 0.3,
  }) {
    // 1. Filtrar auto que colisionan con manual
    final filteredAutoRois = filterAutoRoisCollidingWithManual(
      autoRois: autoRois,
      manualRois: manualRois,
      overlapThreshold: overlapThreshold,
    );

    // 2. Combinar: manuales primero, luego auto filtradas
    return [
      ...manualRois,
      ...filteredAutoRois,
    ];
  }

  /// Verifica si una ROI manual puede ser eliminada
  /// 
  /// Regla: ROIs manuales NUNCA se eliminan automáticamente
  static bool canDeleteManually(ROI roi) {
    return roi.type == RoiType.manual;
  }

  /// Verifica si una ROI puede ser eliminada automáticamente
  /// 
  /// Regla: Solo ROIs automáticas no-locked pueden eliminarse automáticamente
  static bool canDeleteAutomatically(ROI roi) {
    return roi.type == RoiType.faceAuto && !roi.locked;
  }

  /// Convierte una ROI automática a manual cuando el usuario la modifica
  /// 
  /// Regla: Si el usuario ajusta una ROI auto, se convierte en manual
  static ROI convertAutoToManual(ROI autoRoi) {
    return autoRoi.copyWith(
      type: RoiType.manual,
      locked: false, // Las manuales no necesitan locked
    );
  }

  /// Marca una ROI automática como locked cuando el usuario la ajusta
  /// 
  /// Alternativa a convertir a manual: mantener como auto pero locked
  static ROI lockAutoRoi(ROI autoRoi) {
    return autoRoi.copyWith(locked: true);
  }

  /// Valida que una ROI esté dentro de los límites de la imagen
  static bool isValid(ROI roi) {
    return roi.x >= 0.0 &&
           roi.y >= 0.0 &&
           roi.x + roi.width <= 1.0 &&
           roi.y + roi.height <= 1.0 &&
           roi.width > 0.0 &&
           roi.height > 0.0;
  }
}

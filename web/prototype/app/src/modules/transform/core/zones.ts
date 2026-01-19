/**
 * Detección de zonas de transformación (MOVE/ROTATE/NONE)
 */

import type { Point, Shape, TransformZone, TransformConfig } from './types';
import {
  quadCenter,
  insetQuadTowardCenter,
  pointInConvexPolygon,
  pointInCircle,
} from './geometry';

/**
 * Obtiene la zona de transformación para un cuadrilátero
 * - ROTATE: si el punto está en el inner quad (10% hacia el centro)
 * - MOVE: si está en el anillo exterior
 * - NONE: si está fuera
 */
export function getQuadZone(
  pointer: Point,
  quadPoints: [Point, Point, Point, Point],
  config: TransformConfig
): TransformZone {
  // Verificar si está dentro del quad externo
  if (!pointInConvexPolygon(pointer, quadPoints)) {
    return 'NONE';
  }

  // Crear inner quad (10% hacia el centro)
  const innerQuad = insetQuadTowardCenter(quadPoints, config.quadInnerInsetRatio);

  // Si está dentro del inner quad => ROTATE
  if (pointInConvexPolygon(pointer, innerQuad)) {
    return 'ROTATE';
  }

  // Si está en el anillo => MOVE
  return 'MOVE';
}

/**
 * Obtiene la zona de transformación para un círculo
 * - MOVE: siempre (círculos solo se mueven, no rotan)
 * - NONE: si está fuera
 */
export function getCircleZone(
  pointer: Point,
  center: Point,
  radius: number
): TransformZone {
  if (pointInCircle(pointer, center, radius)) {
    return 'MOVE';
  }
  return 'NONE';
}

/**
 * Obtiene la zona de transformación para una forma genérica
 */
export function getZone(
  pointer: Point,
  shape: Shape,
  config: TransformConfig
): TransformZone {
  if (shape.kind === 'circle') {
    return getCircleZone(pointer, shape.center, shape.radius);
  } else {
    return getQuadZone(pointer, shape.points, config);
  }
}

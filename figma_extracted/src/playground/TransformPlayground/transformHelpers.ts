/**
 * Helpers para convertir entre formatos de formas
 * (compatibilidad entre el formato antiguo y el nuevo módulo)
 */

import type { Shape, Point } from '../../modules/transform/core/types';
import { rotatePointAround } from '../../modules/transform/core/geometry';

/**
 * Convierte un rectángulo (x, y, width, height, rotation) a un quad
 */
export function rectToQuad(
  x: number,
  y: number,
  width: number,
  height: number,
  rotation: number = 0
): Shape {
  // Crear los 4 puntos del rectángulo sin rotar
  const halfW = width / 2;
  const halfH = height / 2;
  const centerX = x + halfW;
  const centerY = y + halfH;

  const points: [Point, Point, Point, Point] = [
    { x: centerX - halfW, y: centerY - halfH }, // NW
    { x: centerX + halfW, y: centerY - halfH }, // NE
    { x: centerX + halfW, y: centerY + halfH }, // SE
    { x: centerX - halfW, y: centerY + halfH }, // SW
  ];

  // Aplicar rotación si existe
  if (rotation !== 0) {
    const center: Point = { x: centerX, y: centerY };
    const angleRad = (rotation * Math.PI) / 180;
    return {
      kind: 'quad',
      points: points.map((p) => rotatePointAround(p, center, angleRad)) as [
        Point,
        Point,
        Point,
        Point
      ],
    };
  }

  return { kind: 'quad', points };
}

/**
 * Convierte un quad a un rectángulo (x, y, width, height, rotation)
 */
export function quadToRect(shape: Shape): {
  x: number;
  y: number;
  width: number;
  height: number;
  rotation: number;
} {
  if (shape.kind !== 'quad') {
    throw new Error('Expected quad shape');
  }

  const points = shape.points;

  // Calcular bounding box
  const xs = points.map((p) => p.x);
  const ys = points.map((p) => p.y);
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const minY = Math.min(...ys);
  const maxY = Math.max(...ys);

  const width = maxX - minX;
  const height = maxY - minY;

  // Calcular centro
  const centerX = (minX + maxX) / 2;
  const centerY = (minY + maxY) / 2;

  // Calcular rotación desde el primer punto
  const firstPoint = points[0];
  const dx = firstPoint.x - centerX;
  const dy = firstPoint.y - centerY;
  const angleRad = Math.atan2(dy, dx);
  const rotation = (angleRad * 180) / Math.PI;

  return {
    x: minX,
    y: minY,
    width,
    height,
    rotation: rotation < 0 ? rotation + 360 : rotation,
  };
}

/**
 * Convierte un círculo (x, y, width, height) a la forma del módulo
 */
export function circleToShape(
  x: number,
  y: number,
  width: number,
  height: number
): Shape {
  const radius = Math.min(width, height) / 2;
  const centerX = x + width / 2;
  const centerY = y + height / 2;

  return {
    kind: 'circle',
    center: { x: centerX, y: centerY },
    radius,
  };
}

/**
 * Convierte una forma del módulo a círculo (x, y, width, height)
 */
export function shapeToCircle(shape: Shape): {
  x: number;
  y: number;
  width: number;
  height: number;
} {
  if (shape.kind !== 'circle') {
    throw new Error('Expected circle shape');
  }

  const diameter = shape.radius * 2;
  return {
    x: shape.center.x - shape.radius,
    y: shape.center.y - shape.radius,
    width: diameter,
    height: diameter,
  };
}

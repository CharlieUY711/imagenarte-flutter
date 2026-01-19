/**
 * Utilidades geométricas puras (sin dependencias de React/DOM)
 */

import type { Point, Shape } from './types';

/**
 * Calcula el centro de un cuadrilátero
 */
export function quadCenter(points: [Point, Point, Point, Point]): Point {
  const sumX = points.reduce((acc, p) => acc + p.x, 0);
  const sumY = points.reduce((acc, p) => acc + p.y, 0);
  return {
    x: sumX / 4,
    y: sumY / 4,
  };
}

/**
 * Crea un cuadrilátero interno hacia el centro (para zona de rotación)
 * @param points - Los 4 puntos del quad externo
 * @param ratio - Ratio de inset (0.10 = 10% hacia el centro)
 */
export function insetQuadTowardCenter(
  points: [Point, Point, Point, Point],
  ratio: number
): [Point, Point, Point, Point] {
  const center = quadCenter(points);
  return points.map((p) => ({
    x: p.x + (center.x - p.x) * ratio,
    y: p.y + (center.y - p.y) * ratio,
  })) as [Point, Point, Point, Point];
}

/**
 * Verifica si un punto está dentro de un polígono convexo (usando ray casting)
 */
export function pointInConvexPolygon(point: Point, vertices: Point[]): boolean {
  if (vertices.length < 3) return false;

  let inside = true;
  for (let i = 0; i < vertices.length; i++) {
    const j = (i + 1) % vertices.length;
    const v1 = vertices[i];
    const v2 = vertices[j];

    // Vector del vértice al siguiente
    const edgeX = v2.x - v1.x;
    const edgeY = v2.y - v1.y;

    // Vector del vértice al punto
    const pointX = point.x - v1.x;
    const pointY = point.y - v1.y;

    // Producto cruzado (determina si el punto está a la izquierda o derecha del borde)
    const cross = edgeX * pointY - edgeY * pointX;

    // Si el producto cruzado es negativo, el punto está fuera
    if (cross < 0) {
      inside = false;
      break;
    }
  }

  return inside;
}

/**
 * Verifica si un punto está dentro de un círculo
 */
export function pointInCircle(
  point: Point,
  center: Point,
  radius: number
): boolean {
  const dx = point.x - center.x;
  const dy = point.y - center.y;
  const distanceSq = dx * dx + dy * dy;
  return distanceSq <= radius * radius;
}

/**
 * Rota un punto alrededor de un centro
 */
export function rotatePointAround(
  point: Point,
  center: Point,
  angleRad: number
): Point {
  const cos = Math.cos(angleRad);
  const sin = Math.sin(angleRad);
  const dx = point.x - center.x;
  const dy = point.y - center.y;

  return {
    x: center.x + dx * cos - dy * sin,
    y: center.y + dx * sin + dy * cos,
  };
}

/**
 * Rota un cuadrilátero alrededor de su centro
 */
export function rotateQuad(
  points: [Point, Point, Point, Point],
  center: Point,
  angleRad: number
): [Point, Point, Point, Point] {
  return points.map((p) => rotatePointAround(p, center, angleRad)) as [
    Point,
    Point,
    Point,
    Point
  ];
}

/**
 * Traslada un punto
 */
export function translatePoint(point: Point, dx: number, dy: number): Point {
  return {
    x: point.x + dx,
    y: point.y + dy,
  };
}

/**
 * Traslada un cuadrilátero
 */
export function translateQuad(
  points: [Point, Point, Point, Point],
  dx: number,
  dy: number
): [Point, Point, Point, Point] {
  return points.map((p) => translatePoint(p, dx, dy)) as [
    Point,
    Point,
    Point,
    Point
  ];
}

/**
 * MOTOR UNIFICADO DE TRANSFORMACIÓN
 * 
 * Aplica transformaciones según el modo activo:
 * - move: traslada posición
 * - resize-proportional: escala manteniendo proporción
 * - resize-axis: escala solo en un eje
 */

import type { CircleShape, QuadShape } from './unifiedHitTest';

// ============================================================================
// TIPOS
// ============================================================================

export type TransformMode = 'move' | 'resize-proportional' | 'resize-axis';

export interface TransformConstraints {
  bounds?: {
    minX: number;
    minY: number;
    maxX: number;
    maxY: number;
  };
  minSize?: {
    width?: number;
    height?: number;
    radius?: number;
  };
  maxSize?: {
    width?: number;
    height?: number;
    radius?: number;
  };
}

// ============================================================================
// HELPERS DE CLAMP
// ============================================================================

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

// ============================================================================
// TRANSFORMACIÓN CÍRCULO
// ============================================================================

/**
 * Aplica movimiento a un círculo
 */
export function applyMoveCircle(
  circle: CircleShape,
  deltaX: number,
  deltaY: number,
  constraints?: TransformConstraints
): CircleShape {
  let newCx = circle.cx + deltaX;
  let newCy = circle.cy + deltaY;
  
  // Aplicar límites
  if (constraints?.bounds) {
    newCx = clamp(newCx, constraints.bounds.minX, constraints.bounds.maxX);
    newCy = clamp(newCy, constraints.bounds.minY, constraints.bounds.maxY);
  }
  
  return { ...circle, cx: newCx, cy: newCy };
}

/**
 * Aplica resize proporcional a un círculo
 * 
 * @param circle - Círculo inicial
 * @param startCircle - Círculo cuando comenzó el resize (para mantener centro)
 * @param currentX - Coordenada X actual del puntero
 * @param currentY - Coordenada Y actual del puntero
 * @param constraints - Restricciones opcionales
 */
export function applyResizeCircle(
  circle: CircleShape,
  startCircle: CircleShape,
  currentX: number,
  currentY: number,
  constraints?: TransformConstraints
): CircleShape {
  // Calcular distancia desde el centro inicial hasta el puntero actual
  const dx = currentX - startCircle.cx;
  const dy = currentY - startCircle.cy;
  const newR = Math.hypot(dx, dy);
  
  // Aplicar restricciones de tamaño
  let clampedR = newR;
  if (constraints?.minSize?.radius !== undefined) {
    clampedR = Math.max(clampedR, constraints.minSize.radius);
  }
  if (constraints?.maxSize?.radius !== undefined) {
    clampedR = Math.min(clampedR, constraints.maxSize.radius);
  }
  
  // Asegurar que el círculo no se salga de los límites
  if (constraints?.bounds) {
    const maxRadiusX = Math.min(
      startCircle.cx - constraints.bounds.minX,
      constraints.bounds.maxX - startCircle.cx
    );
    const maxRadiusY = Math.min(
      startCircle.cy - constraints.bounds.minY,
      constraints.bounds.maxY - startCircle.cy
    );
    clampedR = Math.min(clampedR, maxRadiusX, maxRadiusY);
  }
  
  // Mantener el centro inicial y actualizar solo el radio
  return { ...startCircle, r: Math.max(0, clampedR) };
}

// ============================================================================
// TRANSFORMACIÓN QUAD
// ============================================================================

/**
 * Aplica movimiento a un cuadrilátero
 */
export function applyMoveQuad(
  quad: QuadShape,
  deltaX: number,
  deltaY: number,
  constraints?: TransformConstraints
): QuadShape {
  let newX = quad.x + deltaX;
  let newY = quad.y + deltaY;
  
  // Aplicar límites
  if (constraints?.bounds) {
    newX = clamp(newX, constraints.bounds.minX, constraints.bounds.maxX - quad.w);
    newY = clamp(newY, constraints.bounds.minY, constraints.bounds.maxY - quad.h);
  }
  
  return { ...quad, x: newX, y: newY };
}

/**
 * Aplica resize proporcional a un cuadrilátero (desde esquina)
 * 
 * @param quad - Cuadrilátero inicial
 * @param startQuad - Cuadrilátero cuando comenzó el resize
 * @param corner - Esquina activa: 'nw' | 'ne' | 'sw' | 'se'
 * @param currentX - Coordenada X actual del puntero
 * @param currentY - Coordenada Y actual del puntero
 * @param constraints - Restricciones opcionales
 */
export function applyResizeQuadProportional(
  quad: QuadShape,
  startQuad: QuadShape,
  corner: 'nw' | 'ne' | 'sw' | 'se',
  currentX: number,
  currentY: number,
  constraints?: TransformConstraints
): QuadShape {
  // Calcular la esquina opuesta (fija)
  let fixedX: number, fixedY: number;
  if (corner === 'nw') {
    fixedX = startQuad.x + startQuad.w;
    fixedY = startQuad.y + startQuad.h;
  } else if (corner === 'ne') {
    fixedX = startQuad.x;
    fixedY = startQuad.y + startQuad.h;
  } else if (corner === 'sw') {
    fixedX = startQuad.x + startQuad.w;
    fixedY = startQuad.y;
  } else { // se
    fixedX = startQuad.x;
    fixedY = startQuad.y;
  }
  
  // Calcular distancia desde esquina fija hasta puntero actual
  const dx = currentX - fixedX;
  const dy = currentY - fixedY;
  const currentDist = Math.hypot(dx, dy);
  
  // Calcular distancia inicial desde esquina fija hasta esquina activa
  const startDx = (corner === 'nw' || corner === 'sw' ? startQuad.x : startQuad.x + startQuad.w) - fixedX;
  const startDy = (corner === 'nw' || corner === 'ne' ? startQuad.y : startQuad.y + startQuad.h) - fixedY;
  const startDist = Math.hypot(startDx, startDy);
  
  // Factor de escala
  const scaleFactor = startDist > 0 ? currentDist / startDist : 1;
  
  // Mantener relación de aspecto inicial
  const aspectRatio = startQuad.w / startQuad.h;
  let newW = startQuad.w * scaleFactor;
  let newH = startQuad.h * scaleFactor;
  
  // Aplicar restricciones de tamaño
  if (constraints?.minSize) {
    newW = Math.max(newW, constraints.minSize.width ?? 0);
    newH = Math.max(newH, constraints.minSize.height ?? 0);
  }
  if (constraints?.maxSize) {
    newW = Math.min(newW, constraints.maxSize.width ?? Infinity);
    newH = Math.min(newH, constraints.maxSize.height ?? Infinity);
  }
  
  // Ajustar posición según la esquina activa
  let newX = startQuad.x;
  let newY = startQuad.y;
  
  if (corner === 'nw') {
    newX = fixedX - newW;
    newY = fixedY - newH;
  } else if (corner === 'ne') {
    newX = fixedX;
    newY = fixedY - newH;
  } else if (corner === 'sw') {
    newX = fixedX - newW;
    newY = fixedY;
  } else { // se
    newX = fixedX;
    newY = fixedY;
  }
  
  // Asegurar que no se salga de los límites
  if (constraints?.bounds) {
    newX = clamp(newX, constraints.bounds.minX, constraints.bounds.maxX - newW);
    newY = clamp(newY, constraints.bounds.minY, constraints.bounds.maxY - newH);
    newW = Math.min(newW, constraints.bounds.maxX - newX);
    newH = Math.min(newH, constraints.bounds.maxY - newY);
  }
  
  return { x: newX, y: newY, w: newW, h: newH };
}

/**
 * Aplica resize no proporcional a un cuadrilátero (desde lado)
 * 
 * @param quad - Cuadrilátero inicial
 * @param startQuad - Cuadrilátero cuando comenzó el resize
 * @param side - Lado activo: 'n' | 's' | 'e' | 'w'
 * @param currentX - Coordenada X actual del puntero
 * @param currentY - Coordenada Y actual del puntero
 * @param constraints - Restricciones opcionales
 */
export function applyResizeQuadAxis(
  quad: QuadShape,
  startQuad: QuadShape,
  side: 'n' | 's' | 'e' | 'w',
  currentX: number,
  currentY: number,
  constraints?: TransformConstraints
): QuadShape {
  let newX = startQuad.x;
  let newY = startQuad.y;
  let newW = startQuad.w;
  let newH = startQuad.h;
  
  // Ajustar según el lado activo
  if (side === 'n') {
    // Lado superior: cambiar altura, mantener lado inferior fijo
    const deltaY = currentY - (startQuad.y + startQuad.h);
    newH = startQuad.h - deltaY;
    newY = startQuad.y + deltaY;
  } else if (side === 's') {
    // Lado inferior: cambiar altura, mantener lado superior fijo
    const deltaY = currentY - startQuad.y;
    newH = deltaY;
  } else if (side === 'e') {
    // Lado derecho: cambiar ancho, mantener lado izquierdo fijo
    const deltaX = currentX - startQuad.x;
    newW = deltaX;
  } else { // w
    // Lado izquierdo: cambiar ancho, mantener lado derecho fijo
    const deltaX = currentX - (startQuad.x + startQuad.w);
    newW = startQuad.w - deltaX;
    newX = startQuad.x + deltaX;
  }
  
  // Aplicar restricciones de tamaño
  if (constraints?.minSize) {
    newW = Math.max(newW, constraints.minSize.width ?? 0);
    newH = Math.max(newH, constraints.minSize.height ?? 0);
  }
  if (constraints?.maxSize) {
    newW = Math.min(newW, constraints.maxSize.width ?? Infinity);
    newH = Math.min(newH, constraints.maxSize.height ?? Infinity);
  }
  
  // Asegurar que no se salga de los límites
  if (constraints?.bounds) {
    newX = clamp(newX, constraints.bounds.minX, constraints.bounds.maxX - newW);
    newY = clamp(newY, constraints.bounds.minY, constraints.bounds.maxY - newH);
    newW = Math.min(newW, constraints.bounds.maxX - newX);
    newH = Math.min(newH, constraints.bounds.maxY - newY);
  }
  
  return { x: newX, y: newY, w: newW, h: newH };
}

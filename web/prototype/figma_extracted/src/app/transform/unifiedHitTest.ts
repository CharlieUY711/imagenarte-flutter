/**
 * SISTEMA CANÓNICO DE HIT-TEST
 * 
 * Define tolerancias y funciones de detección de zonas para:
 * - Círculos (resize proporcional siempre)
 * - Cuadriláteros (esquinas proporcional, lados no proporcional)
 * 
 * REGLAS:
 * - EDGE_T = 12px (tolerancia para borde)
 * - CORNER_ZONE = 5% del lado más pequeño (solo para QUAD)
 */

// ============================================================================
// CONSTANTES
// ============================================================================

export const EDGE_T = 12; // Tolerancia para borde (píxeles)
export const CORNER_ZONE_RATIO = 0.05; // 5% del lado más pequeño

// ============================================================================
// TIPOS
// ============================================================================

export type TransformMode = 'move' | 'resize-proportional' | 'resize-axis' | null;

export interface CircleShape {
  cx: number;
  cy: number;
  r: number;
}

export interface QuadShape {
  x: number; // esquina superior izquierda
  y: number;
  w: number; // ancho
  h: number; // alto
}

// ============================================================================
// HIT-TEST CÍRCULO
// ============================================================================

/**
 * Detecta la zona activa en un círculo
 * 
 * @param px - Coordenada X del punto (local al contenedor)
 * @param py - Coordenada Y del punto (local al contenedor)
 * @param circle - Círculo { cx, cy, r }
 * @returns Modo: 'resize-proportional' | 'move' | null
 */
export function hitTestCircle(
  px: number,
  py: number,
  circle: CircleShape
): TransformMode {
  const dx = px - circle.cx;
  const dy = py - circle.cy;
  const dist = Math.hypot(dx, dy);
  
  // Resize: cerca del borde (dentro de EDGE_T)
  if (Math.abs(dist - circle.r) <= EDGE_T) {
    return 'resize-proportional';
  }
  
  // Move: dentro del círculo (fuera de la zona de borde)
  if (dist < circle.r - EDGE_T) {
    return 'move';
  }
  
  // Nada: fuera del círculo
  return null;
}

// ============================================================================
// HIT-TEST QUAD
// ============================================================================

/**
 * Detecta la zona activa en un cuadrilátero
 * 
 * @param px - Coordenada X del punto (local al contenedor)
 * @param py - Coordenada Y del punto (local al contenedor)
 * @param quad - Cuadrilátero { x, y, w, h }
 * @returns Modo: 'resize-proportional' | 'resize-axis' | 'move' | null
 */
export function hitTestQuad(
  px: number,
  py: number,
  quad: QuadShape
): TransformMode {
  // Coordenadas relativas al cuadrilátero
  const relX = px - quad.x;
  const relY = py - quad.y;
  
  // Verificar si está dentro del rectángulo
  if (relX < 0 || relX > quad.w || relY < 0 || relY > quad.h) {
    return null; // Fuera del rectángulo
  }
  
  // Tamaño de zona de esquina (5% del lado más pequeño)
  const cornerSize = Math.min(quad.w, quad.h) * CORNER_ZONE_RATIO;
  
  // Detectar esquinas (prioridad máxima)
  const distFromNW = Math.hypot(relX - 0, relY - 0);
  const distFromNE = Math.hypot(relX - quad.w, relY - 0);
  const distFromSW = Math.hypot(relX - 0, relY - quad.h);
  const distFromSE = Math.hypot(relX - quad.w, relY - quad.h);
  
  if (distFromNW < cornerSize || distFromNE < cornerSize || 
      distFromSW < cornerSize || distFromSE < cornerSize) {
    return 'resize-proportional';
  }
  
  // Detectar lados (excluyendo el 5% cercano a cada esquina)
  const isNearTop = relY < EDGE_T && relX > cornerSize && relX < quad.w - cornerSize;
  const isNearBottom = relY > quad.h - EDGE_T && relX > cornerSize && relX < quad.w - cornerSize;
  const isNearLeft = relX < EDGE_T && relY > cornerSize && relY < quad.h - cornerSize;
  const isNearRight = relX > quad.w - EDGE_T && relY > cornerSize && relY < quad.h - cornerSize;
  
  if (isNearTop || isNearBottom || isNearLeft || isNearRight) {
    return 'resize-axis';
  }
  
  // Interior: move
  return 'move';
}

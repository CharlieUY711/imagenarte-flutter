/**
 * Motor puro de transformaciones (sin React, sin DOM)
 * 
 * Proporciona funciones deterministas y testeables para transformar
 * rectángulos y círculos mediante mover, escalar, rotar y estirar.
 */

// ============================================================================
// TIPOS
// ============================================================================

/**
 * Representa un rectángulo/cuadrilátero con centro, dimensiones y rotación
 */
export interface RectLike {
  cx: number; // Centro X
  cy: number; // Centro Y
  w: number;  // Ancho
  h: number;  // Alto
  rotation: number; // Rotación en grados (0-360)
}

/**
 * Representa un círculo con centro y radio
 */
export interface CircleLike {
  cx: number; // Centro X
  cy: number; // Centro Y
  r: number;  // Radio
}

/**
 * Forma genérica: rectángulo o círculo
 */
export type Shape = RectLike | CircleLike;

/**
 * Tipo de forma para identificar qué tipo de Shape es
 */
export type ShapeType = 'rect' | 'circle';

/**
 * Handles de transformación disponibles
 */
export type TransformHandle =
  | 'move'      // Mover la forma completa
  | 'rotate'    // Rotar la forma
  | 'n'         // Norte (arriba) - resize
  | 's'         // Sur (abajo) - resize
  | 'e'         // Este (derecha) - resize
  | 'w'         // Oeste (izquierda) - resize
  | 'ne'        // Noreste (esquina superior derecha) - resize
  | 'nw'        // Noroeste (esquina superior izquierda) - resize
  | 'se'        // Sureste (esquina inferior derecha) - resize
  | 'sw'        // Suroeste (esquina inferior izquierda) - resize
  | 'radius';   // Radio (solo para círculos)

/**
 * Restricciones de transformación
 */
export interface TransformConstraints {
  /** Límites del contenedor { minX, minY, maxX, maxY } */
  bounds?: {
    minX: number;
    minY: number;
    maxX: number;
    maxY: number;
  };
  /** Tamaño mínimo { width, height } o { radius } */
  minSize?: { width?: number; height?: number; radius?: number };
  /** Tamaño máximo { width, height } o { radius } */
  maxSize?: { width?: number; height?: number; radius?: number };
  /** Bloquear relación de aspecto (solo para rectángulos) */
  lockAspect?: boolean;
  /** Relación de aspecto a mantener (solo si lockAspect es true) */
  aspectRatio?: number;
  /** Snap de rotación (múltiplos de grados) */
  snapRotation?: number;
  /** Umbral de snap de rotación (grados de tolerancia) */
  snapRotationThreshold?: number;
}

/**
 * Delta de transformación (cambio en coordenadas)
 */
export interface TransformDelta {
  dx: number; // Delta X
  dy: number; // Delta Y
}

// ============================================================================
// HELPERS DE CLAMP Y BOUNDS
// ============================================================================

/**
 * Limita un valor entre min y max
 */
export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

/**
 * Normaliza un ángulo a rango 0-360
 */
export function normalizeAngle(angle: number): number {
  return ((angle % 360) + 360) % 360;
}

/**
 * Aplica snap de rotación si está configurado
 */
export function applyRotationSnap(
  angle: number,
  snapAngle?: number,
  threshold?: number
): number {
  if (!snapAngle) return normalizeAngle(angle);
  
  const normalized = normalizeAngle(angle);
  const snapped = Math.round(normalized / snapAngle) * snapAngle;
  const snappedNormalized = normalizeAngle(snapped);
  
  if (threshold) {
    let distance = Math.abs(normalized - snappedNormalized);
    if (distance > 180) distance = 360 - distance;
    if (distance <= threshold) {
      return snappedNormalized;
    }
  }
  
  return normalized;
}

/**
 * Aplica restricciones de límites a una posición
 */
export function applyBounds(
  x: number,
  y: number,
  bounds?: TransformConstraints['bounds']
): { x: number; y: number } {
  if (!bounds) return { x, y };
  return {
    x: clamp(x, bounds.minX, bounds.maxX),
    y: clamp(y, bounds.minY, bounds.maxY),
  };
}

/**
 * Aplica restricciones de tamaño a un rectángulo
 */
export function applySizeConstraints(
  width: number,
  height: number,
  constraints: TransformConstraints
): { width: number; height: number } {
  let w = width;
  let h = height;
  
  if (constraints.minSize) {
    w = Math.max(w, constraints.minSize.width ?? 0);
    h = Math.max(h, constraints.minSize.height ?? 0);
  }
  
  if (constraints.maxSize) {
    w = Math.min(w, constraints.maxSize.width ?? Infinity);
    h = Math.min(h, constraints.maxSize.height ?? Infinity);
  }
  
  return { width: w, height: h };
}

/**
 * Aplica restricciones de tamaño a un círculo
 */
export function applyRadiusConstraints(
  radius: number,
  constraints: TransformConstraints
): number {
  let r = radius;
  
  if (constraints.minSize?.radius !== undefined) {
    r = Math.max(r, constraints.minSize.radius);
  }
  
  if (constraints.maxSize?.radius !== undefined) {
    r = Math.min(r, constraints.maxSize.radius);
  }
  
  return r;
}

// ============================================================================
// FUNCIÓN PRINCIPAL: applyTransform
// ============================================================================

/**
 * Aplica una transformación a una forma según el handle y delta dados
 * 
 * @param shape - La forma a transformar (RectLike o CircleLike)
 * @param shapeType - Tipo de forma ('rect' o 'circle')
 * @param handle - Handle de transformación activo
 * @param delta - Delta de movimiento (dx, dy)
 * @param constraints - Restricciones opcionales
 * @param startShape - Forma inicial cuando comenzó la transformación (para resize)
 * @param startMouse - Posición inicial del mouse (para rotación)
 * @returns Nueva forma transformada
 */
export function applyTransform(
  shape: Shape,
  shapeType: ShapeType,
  handle: TransformHandle,
  delta: TransformDelta,
  constraints?: TransformConstraints,
  startShape?: Shape,
  startMouse?: { x: number; y: number },
  currentMouse?: { x: number; y: number }
): Shape {
  if (shapeType === 'circle') {
    return applyTransformToCircle(
      shape as CircleLike,
      handle,
      delta,
      constraints,
      startShape as CircleLike | undefined,
      startMouse,
      currentMouse
    );
  } else {
    return applyTransformToRect(
      shape as RectLike,
      handle,
      delta,
      constraints,
      startShape as RectLike | undefined,
      startMouse,
      currentMouse
    );
  }
}

/**
 * Aplica transformación a un círculo
 */
function applyTransformToCircle(
  circle: CircleLike,
  handle: TransformHandle,
  delta: TransformDelta,
  constraints?: TransformConstraints,
  startCircle?: CircleLike,
  startMouse?: { x: number; y: number },
  currentMouse?: { x: number; y: number }
): CircleLike {
  switch (handle) {
    case 'move': {
      const newCx = circle.cx + delta.dx;
      const newCy = circle.cy + delta.dy;
      const bounded = applyBounds(newCx, newCy, constraints?.bounds);
      return { ...circle, cx: bounded.x, cy: bounded.y };
    }
    
    case 'radius': {
      if (!startCircle || !startMouse || !currentMouse) {
        return circle;
      }
      
      // IMPORTANTE: Usar el centro del círculo INICIAL (startCircle) para mantener el centro fijo
      // durante el resize. Esto asegura que el cálculo sea invariante a cuadrantes.
      const centerX = startCircle.cx;
      const centerY = startCircle.cy;
      
      // Calcular distancia desde el centro INICIAL hasta el mouse actual usando hypot (invariante a cuadrantes)
      const dx = currentMouse.x - centerX;
      const dy = currentMouse.y - centerY;
      const currentDist = Math.hypot(dx, dy);
      
      // Log de instrumentación (temporal) - PASO 1
      const DEBUG_RADIUS = true;
      if (DEBUG_RADIUS) {
        const quadrant = (dx >= 0 ? 'R' : 'L') + (dy >= 0 ? 'D' : 'U');
        console.log('[transformEngine] radius calculation', {
          localX: currentMouse.x,
          localY: currentMouse.y,
          cx: centerX,
          cy: centerY,
          dx,
          dy,
          dist: currentDist,
          quadrant,
          radiusPrev: circle.r,
        });
      }
      
      // PASO 2: Usar la distancia euclídea como nuevo radio (invariante a cuadrantes)
      let newRadius = currentDist;
      newRadius = applyRadiusConstraints(newRadius, constraints || {});
      
      // Asegurar que el círculo no se salga de los límites
      if (constraints?.bounds) {
        const maxRadiusX = Math.min(
          centerX - constraints.bounds.minX,
          constraints.bounds.maxX - centerX
        );
        const maxRadiusY = Math.min(
          centerY - constraints.bounds.minY,
          constraints.bounds.maxY - centerY
        );
        newRadius = Math.min(newRadius, maxRadiusX, maxRadiusY);
      }
      
      const radiusNext = Math.max(0, newRadius);
      
      if (DEBUG_RADIUS) {
        console.log('[transformEngine] radius result', {
          radiusNext,
          delta: radiusNext - circle.r,
        });
      }
      
      // Mantener el centro del círculo inicial durante el resize
      return { ...startCircle, r: radiusNext };
    }
    
    default:
      return circle;
  }
}

/**
 * Aplica transformación a un rectángulo
 */
function applyTransformToRect(
  rect: RectLike,
  handle: TransformHandle,
  delta: TransformDelta,
  constraints?: TransformConstraints,
  startRect?: RectLike,
  startMouse?: { x: number; y: number },
  currentMouse?: { x: number; y: number }
): RectLike {
  switch (handle) {
    case 'move': {
      const newCx = rect.cx + delta.dx;
      const newCy = rect.cy + delta.dy;
      const bounded = applyBounds(newCx, newCy, constraints?.bounds);
      return { ...rect, cx: bounded.x, cy: bounded.y };
    }
    
    case 'rotate': {
      if (!startRect || !startMouse || !currentMouse) {
        return rect;
      }
      
      // Calcular ángulo desde el centro hasta el mouse
      const centerX = rect.cx;
      const centerY = rect.cy;
      
      const currentAngle = Math.atan2(
        currentMouse.y - centerY,
        currentMouse.x - centerX
      ) * (180 / Math.PI);
      
      const startAngle = Math.atan2(
        startMouse.y - centerY,
        startMouse.x - centerX
      ) * (180 / Math.PI);
      
      let deltaAngle = currentAngle - startAngle;
      if (deltaAngle > 180) deltaAngle -= 360;
      if (deltaAngle < -180) deltaAngle += 360;
      
      let newRotation = startRect.rotation + deltaAngle;
      newRotation = applyRotationSnap(
        newRotation,
        constraints?.snapRotation,
        constraints?.snapRotationThreshold
      );
      
      // Normalizar a rango 0-360 usando módulo para mantener continuidad
      // Esto evita el salto de 359 a 0 y permite mostrar 360° correctamente
      newRotation = ((newRotation % 360) + 360) % 360;
      // Si el valor es muy cercano a 360, mantenerlo como 360 (no convertir a 0)
      if (newRotation > 359.5) {
        newRotation = 360;
      } else if (newRotation < 0.5 && newRotation > -0.5) {
        newRotation = 0;
      }
      
      return { ...rect, rotation: newRotation };
    }
    
    case 'n':
    case 's':
    case 'e':
    case 'w':
    case 'ne':
    case 'nw':
    case 'se':
    case 'sw': {
      if (!startRect) {
        return rect;
      }
      
      // Calcular nuevo tamaño y posición según el handle
      const halfW = startRect.w / 2;
      const halfH = startRect.h / 2;
      
      let newW = startRect.w;
      let newH = startRect.h;
      let newCx = startRect.cx;
      let newCy = startRect.cy;
      
      // Aplicar delta según el handle
      // Para mantener el lado opuesto fijo:
      // - Norte (n): lado sur fijo, centro se mueve hacia arriba cuando arrastras hacia arriba
      // - Sur (s): lado norte fijo, centro se mueve hacia abajo cuando arrastras hacia abajo
      // - Este (e): lado oeste fijo, centro se mueve hacia la derecha cuando arrastras hacia la derecha
      // - Oeste (w): lado este fijo, centro se mueve hacia la izquierda cuando arrastras hacia la izquierda
      if (handle === 'n' || handle === 'ne' || handle === 'nw') {
        // Lado norte: arrastrar hacia arriba (delta.dy negativo) aumenta altura
        // El lado sur permanece fijo, así que el centro se mueve hacia arriba
        newH = startRect.h - delta.dy;
        newCy = startRect.cy + delta.dy / 2;
      }
      if (handle === 's' || handle === 'se' || handle === 'sw') {
        // Lado sur: arrastrar hacia abajo (delta.dy positivo) aumenta altura
        // El lado norte permanece fijo, así que el centro se mueve hacia abajo
        newH = startRect.h + delta.dy;
        newCy = startRect.cy + delta.dy / 2;
      }
      if (handle === 'e' || handle === 'ne' || handle === 'se') {
        // Lado este: arrastrar hacia la derecha (delta.dx positivo) aumenta ancho
        // El lado oeste permanece fijo, así que el centro se mueve hacia la derecha
        newW = startRect.w + delta.dx;
        newCx = startRect.cx + delta.dx / 2;
      }
      if (handle === 'w' || handle === 'nw' || handle === 'sw') {
        // Lado oeste: arrastrar hacia la izquierda (delta.dx negativo) aumenta ancho
        // El lado este permanece fijo, así que el centro se mueve hacia la izquierda
        newW = startRect.w - delta.dx;
        newCx = startRect.cx + delta.dx / 2;
      }
      
      // Aplicar lock de aspecto si está configurado
      if (constraints?.lockAspect && constraints?.aspectRatio) {
        const aspectRatio = constraints.aspectRatio;
        const currentAspect = newW / newH;
        
        if (Math.abs(currentAspect - aspectRatio) > 0.01) {
          // Ajustar para mantener aspecto
          if (handle === 'n' || handle === 's') {
            newW = newH * aspectRatio;
          } else if (handle === 'e' || handle === 'w') {
            newH = newW / aspectRatio;
          } else {
            // Para esquinas, usar el promedio
            const avgSize = (newW + newH) / 2;
            newW = avgSize * Math.sqrt(aspectRatio);
            newH = avgSize / Math.sqrt(aspectRatio);
          }
          
          // Recalcular centro manteniendo el lado opuesto fijo
          newCx = startRect.cx;
          newCy = startRect.cy;
          
          // Cambio de altura
          const deltaH = newH - startRect.h;
          // Cambio de ancho
          const deltaW = newW - startRect.w;
          
          if (handle === 'n' || handle === 'ne' || handle === 'nw') {
            // Lado norte: el lado sur permanece fijo, centro se mueve hacia arriba
            newCy = startRect.cy - deltaH / 2;
          }
          if (handle === 's' || handle === 'se' || handle === 'sw') {
            // Lado sur: el lado norte permanece fijo, centro se mueve hacia abajo
            newCy = startRect.cy + deltaH / 2;
          }
          if (handle === 'e' || handle === 'ne' || handle === 'se') {
            // Lado este: el lado oeste permanece fijo, centro se mueve hacia la derecha
            newCx = startRect.cx + deltaW / 2;
          }
          if (handle === 'w' || handle === 'nw' || handle === 'sw') {
            // Lado oeste: el lado este permanece fijo, centro se mueve hacia la izquierda
            newCx = startRect.cx - deltaW / 2;
          }
        }
      }
      
      // Aplicar restricciones de tamaño
      const sizeConstrained = applySizeConstraints(newW, newH, constraints || {});
      newW = sizeConstrained.width;
      newH = sizeConstrained.height;
      
      // Asegurar que no se salga de los límites
      if (constraints?.bounds) {
        const minCx = constraints.bounds.minX + newW / 2;
        const maxCx = constraints.bounds.maxX - newW / 2;
        const minCy = constraints.bounds.minY + newH / 2;
        const maxCy = constraints.bounds.maxY - newH / 2;
        
        newCx = clamp(newCx, minCx, maxCx);
        newCy = clamp(newCy, minCy, maxCy);
      }
      
      return { ...rect, cx: newCx, cy: newCy, w: newW, h: newH };
    }
    
    default:
      return rect;
  }
}

// ============================================================================
// HELPERS DE CONVERSIÓN
// ============================================================================

/**
 * Convierte un RectLike a formato { x, y, width, height, rotation }
 */
export function rectToPositionSize(rect: RectLike): {
  x: number;
  y: number;
  width: number;
  height: number;
  rotation: number;
} {
  return {
    x: rect.cx - rect.w / 2,
    y: rect.cy - rect.h / 2,
    width: rect.w,
    height: rect.h,
    rotation: rect.rotation,
  };
}

/**
 * Convierte { x, y, width, height, rotation } a RectLike
 */
export function positionSizeToRect(
  x: number,
  y: number,
  width: number,
  height: number,
  rotation: number = 0
): RectLike {
  return {
    cx: x + width / 2,
    cy: y + height / 2,
    w: width,
    h: height,
    rotation,
  };
}

/**
 * Convierte un CircleLike a formato { x, y, width, height }
 */
export function circleToPositionSize(circle: CircleLike): {
  x: number;
  y: number;
  width: number;
  height: number;
} {
  return {
    x: circle.cx - circle.r,
    y: circle.cy - circle.r,
    width: circle.r * 2,
    height: circle.r * 2,
  };
}

/**
 * Convierte { x, y, width, height } a CircleLike
 */
export function positionSizeToCircle(
  x: number,
  y: number,
  width: number,
  height: number
): CircleLike {
  const radius = Math.min(width, height) / 2;
  return {
    cx: x + width / 2,
    cy: y + height / 2,
    r: radius,
  };
}

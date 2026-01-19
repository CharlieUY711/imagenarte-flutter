/**
 * Hook reutilizable para gestos de transformación
 * 
 * Maneja eventos de pointer para transformar formas usando el motor puro.
 * Proporciona handlers y estado para integrar con componentes React.
 */

import { useState, useRef, useEffect, useCallback } from 'react';
import {
  Shape,
  ShapeType,
  TransformHandle,
  TransformConstraints,
  TransformDelta,
  applyTransform,
  RectLike,
  CircleLike,
  positionSizeToRect,
  positionSizeToCircle,
  rectToPositionSize,
  circleToPositionSize,
} from './transformEngine';
import { getLocalPoint, getScaleFactor, getLocalDelta } from '../../utils/pointer';

// ============================================================================
// TIPOS
// ============================================================================

/**
 * Formato de entrada para rectángulos (compatible con CropOverlay)
 */
export interface RectInput {
  x: number;
  y: number;
  width: number;
  height: number;
  rotation?: number;
}

/**
 * Formato de entrada para círculos (compatible con CropOverlay)
 */
export interface CircleInput {
  x: number;
  y: number;
  width: number;
  height: number;
}

/**
 * Formato de entrada genérico
 */
export type ShapeInput = RectInput | CircleInput;

/**
 * Opciones para el hook
 */
export interface UseTransformGesturesOptions {
  /** Forma actual (en formato de entrada) */
  shape: ShapeInput;
  /** Tipo de forma */
  shapeType: ShapeType;
  /** Callback cuando la forma cambia */
  onShapeChange: (shape: ShapeInput) => void;
  /** Restricciones de transformación */
  constraints?: TransformConstraints;
  /** Callback opcional cuando comienza una transformación */
  onTransformStart?: () => void;
  /** Callback opcional cuando termina una transformación */
  onTransformEnd?: () => void;
  /** Umbral de distancia para detectar handles (píxeles) */
  handleThreshold?: number;
  /** Umbral de distancia para detectar borde de círculo (píxeles) */
  circleEdgeThreshold?: number;
  /** Ref del contenedor para calcular coordenadas locales y scale */
  containerRef?: React.RefObject<HTMLElement>;
  /** Selector CSS del contenedor (fallback si no hay ref) */
  containerSelector?: string;
}

// ============================================================================
// HOOK PRINCIPAL
// ============================================================================

/**
 * Hook para manejar gestos de transformación
 */
export function useTransformGestures({
  shape,
  shapeType,
  onShapeChange,
  constraints,
  onTransformStart,
  onTransformEnd,
  handleThreshold = 8,
  circleEdgeThreshold = 12,
  containerRef: externalContainerRef,
  containerSelector = '.preview-image-container',
}: UseTransformGesturesOptions) {
  const [activeHandle, setActiveHandle] = useState<TransformHandle | null>(null);
  const [isTransforming, setIsTransforming] = useState(false);
  
  const startShapeRef = useRef<Shape | null>(null);
  const startMouseRef = useRef<{ x: number; y: number } | null>(null);
  const startMouseLocalRef = useRef<{ x: number; y: number } | null>(null);
  const shapeElementRef = useRef<HTMLElement | null>(null);
  const containerElementRef = useRef<HTMLElement | null>(null);
  const scaleRef = useRef<number>(1.0);

  // Convertir shape de entrada a formato interno
  const shapeToInternal = useCallback((s: ShapeInput): Shape => {
    if (shapeType === 'circle') {
      return positionSizeToCircle(s.x, s.y, s.width, s.height);
    } else {
      const rect = s as RectInput;
      return positionSizeToRect(
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        rect.rotation || 0
      );
    }
  }, [shapeType]);

  // Convertir shape interno a formato de salida
  const shapeToOutput = useCallback((s: Shape): ShapeInput => {
    if (shapeType === 'circle') {
      const pos = circleToPositionSize(s as CircleLike);
      return { x: pos.x, y: pos.y, width: pos.width, height: pos.height };
    } else {
      const pos = rectToPositionSize(s as RectLike);
      return {
        x: pos.x,
        y: pos.y,
        width: pos.width,
        height: pos.height,
        rotation: pos.rotation,
      };
    }
  }, [shapeType]);

  // Detectar handle desde coordenadas del mouse
  const detectHandle = useCallback((
    mouseX: number,
    mouseY: number,
    shapeRect: DOMRect,
    internalShape: Shape
  ): TransformHandle | null => {
    if (shapeType === 'circle') {
      const circle = internalShape as CircleLike;
      const centerX = shapeRect.left + shapeRect.width / 2;
      const centerY = shapeRect.top + shapeRect.height / 2;
      const distanceFromCenter = Math.sqrt(
        (mouseX - centerX) ** 2 + (mouseY - centerY) ** 2
      );
      const radius = circle.r;
      
      // Detectar si está cerca del borde
      if (Math.abs(distanceFromCenter - radius) < circleEdgeThreshold) {
        return 'radius';
      }
      
      // Si no, es movimiento
      return 'move';
    } else {
      const rect = internalShape as RectLike;
      const shapeX = shapeRect.left;
      const shapeY = shapeRect.top;
      const shapeW = shapeRect.width;
      const shapeH = shapeRect.height;
      
      // Coordenadas relativas al elemento
      const relX = mouseX - shapeX;
      const relY = mouseY - shapeY;
      
      // Detectar esquinas
      const cornerSize = handleThreshold * 2;
      
      if (relX < cornerSize && relY < cornerSize) return 'nw';
      if (relX > shapeW - cornerSize && relY < cornerSize) return 'ne';
      if (relX < cornerSize && relY > shapeH - cornerSize) return 'sw';
      if (relX > shapeW - cornerSize && relY > shapeH - cornerSize) return 'se';
      
      // Detectar bordes
      if (relY < handleThreshold) return 'n';
      if (relY > shapeH - handleThreshold) return 's';
      if (relX < handleThreshold) return 'w';
      if (relX > shapeW - handleThreshold) return 'e';
      
      // Si no, es movimiento
      return 'move';
    }
  }, [shapeType, handleThreshold, circleEdgeThreshold]);

  // Obtener contenedor
  const getContainer = useCallback((): HTMLElement | null => {
    if (externalContainerRef?.current) {
      return externalContainerRef.current;
    }
    if (containerElementRef.current) {
      return containerElementRef.current;
    }
    const found = document.querySelector(containerSelector) as HTMLElement;
    if (found) {
      containerElementRef.current = found;
      return found;
    }
    return null;
  }, [externalContainerRef, containerSelector]);

  // Handler de inicio de transformación
  const handlePointerDown = useCallback((
    e: React.PointerEvent,
    element?: HTMLElement,
    explicitHandle?: TransformHandle
  ) => {
    e.stopPropagation();
    
    if (element) {
      shapeElementRef.current = element;
    }
    
    const shapeRect = element?.getBoundingClientRect();
    if (!shapeRect) return;
    
    const containerElement = getContainer();
    if (!containerElement) {
      console.warn('useTransformGestures: No se encontró contenedor');
      return;
    }
    
    const scale = getScaleFactor(containerElement);
    scaleRef.current = scale;
    
    const internalShape = shapeToInternal(shape);
    
    // Prioridad de detección de handle:
    // 1. Handle explícito pasado como parámetro
    // 2. data-handle del elemento target
    // 3. Detección por posición del mouse
    let handle: TransformHandle | null = null;
    
    if (explicitHandle) {
      handle = explicitHandle;
    } else {
      // Buscar data-handle en el target o sus padres (hasta 2 niveles)
      let target = e.target as HTMLElement;
      let depth = 0;
      while (target && depth < 2) {
        const handleAttr = target.dataset.handle;
        if (handleAttr && (handleAttr === 'move' || handleAttr === 'rotate' || 
            handleAttr === 'nw' || handleAttr === 'ne' || handleAttr === 'sw' || handleAttr === 'se' ||
            handleAttr === 'n' || handleAttr === 's' || handleAttr === 'e' || handleAttr === 'w' ||
            handleAttr === 'radius' || handleAttr === 'rot')) {
          handle = handleAttr as TransformHandle;
          if (handleAttr === 'rot') handle = 'rotate';
          break;
        }
        target = target.parentElement as HTMLElement;
        depth++;
      }
      
      // Si no se encontró en data-handle, detectar por posición
      if (!handle) {
        handle = detectHandle(e.clientX, e.clientY, shapeRect, internalShape);
      }
    }
    
    if (!handle) return;
    
    setActiveHandle(handle);
    setIsTransforming(true);
    startShapeRef.current = internalShape;
    
    // Obtener coordenadas locales del puntero
    const localPoint = getLocalPoint(e, containerElement);
    startMouseLocalRef.current = localPoint;
    
    // Para rotación, guardar el centro en coordenadas locales del contenedor
    if (handle === 'rotate' && shapeType === 'rect') {
      const rect = internalShape as RectLike;
      startMouseRef.current = { x: rect.cx, y: rect.cy };
      startMouseLocalRef.current = { x: rect.cx, y: rect.cy };
    } else if (handle === 'radius' && shapeType === 'circle') {
      const circle = internalShape as CircleLike;
      startMouseRef.current = { x: circle.cx, y: circle.cy };
      startMouseLocalRef.current = { x: circle.cx, y: circle.cy };
    } else {
      // Para otros handles, usar coordenadas locales
      startMouseRef.current = { x: e.clientX, y: e.clientY }; // Mantener para compatibilidad
      startMouseLocalRef.current = localPoint;
    }
    
    onTransformStart?.();
    
    // Pointer capture
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch (err) {
      console.warn('setPointerCapture failed:', err);
    }
  }, [shape, shapeType, shapeToInternal, detectHandle, onTransformStart, getContainer]);

  // Handler de movimiento durante transformación
  const handlePointerMove = useCallback((e: PointerEvent) => {
    if (!isTransforming || !activeHandle || !startShapeRef.current || !startMouseLocalRef.current) {
      return;
    }
    
    const containerElement = getContainer();
    if (!containerElement) return;
    
    const scale = scaleRef.current;
    const currentLocalPoint = getLocalPoint(e, containerElement);
    
    // Para rotación, usar coordenadas locales del contenedor
    if (activeHandle === 'rotate' && shapeType === 'rect') {
      const rect = startShapeRef.current as RectLike;
      const centerLocal = { x: rect.cx, y: rect.cy };
      
      const newShape = applyTransform(
        startShapeRef.current,
        shapeType,
        activeHandle,
        { dx: 0, dy: 0 },
        constraints,
        startShapeRef.current,
        centerLocal,
        currentLocalPoint
      );
      
      onShapeChange(shapeToOutput(newShape));
      return;
    }
    
    // Para radius (círculo), usar coordenadas locales
    if (activeHandle === 'radius' && shapeType === 'circle') {
      const circle = startShapeRef.current as CircleLike;
      const centerLocal = { x: circle.cx, y: circle.cy };
      
      // PASO 1: Log de instrumentación completo (temporal)
      const DEBUG_RADIUS = true;
      if (DEBUG_RADIUS) {
        const dx = currentLocalPoint.x - centerLocal.x;
        const dy = currentLocalPoint.y - centerLocal.y;
        const dist = Math.hypot(dx, dy);
        const quadrant = (dx >= 0 ? 'R' : 'L') + (dy >= 0 ? 'D' : 'U');
        console.log('[useTransformGestures] radius pointerMove', {
          localX: currentLocalPoint.x,
          localY: currentLocalPoint.y,
          cx: centerLocal.x,
          cy: centerLocal.y,
          dx,
          dy,
          dist,
          quadrant,
          radiusPrev: circle.r,
        });
      }
      
      const newShape = applyTransform(
        startShapeRef.current,
        shapeType,
        activeHandle,
        { dx: 0, dy: 0 },
        constraints,
        startShapeRef.current,
        centerLocal,
        currentLocalPoint
      );
      
      if (DEBUG_RADIUS) {
        const newCircle = newShape as CircleLike;
        const dx = currentLocalPoint.x - centerLocal.x;
        const dy = currentLocalPoint.y - centerLocal.y;
        const dist = Math.hypot(dx, dy);
        const quadrant = (dx >= 0 ? 'R' : 'L') + (dy >= 0 ? 'D' : 'U');
        console.log('[useTransformGestures] radius result', {
          localX: currentLocalPoint.x,
          localY: currentLocalPoint.y,
          cx: centerLocal.x,
          cy: centerLocal.y,
          dx,
          dy,
          dist,
          quadrant,
          radiusPrev: circle.r,
          radiusNext: newCircle.r,
          delta: newCircle.r - circle.r,
        });
      }
      
      onShapeChange(shapeToOutput(newShape));
      return;
    }
    
    // Para otros handles, calcular delta local con scale
    const delta = getLocalDelta(startMouseLocalRef.current, currentLocalPoint, scale);
    
    // Configurar constraints dinámicamente según el handle
    let dynamicConstraints = constraints;
    if (shapeType === 'rect' && startShapeRef.current) {
      const startRect = startShapeRef.current as RectLike;
      const isCorner = activeHandle === 'nw' || activeHandle === 'ne' || activeHandle === 'sw' || activeHandle === 'se';
      const isEdge = activeHandle === 'n' || activeHandle === 's' || activeHandle === 'e' || activeHandle === 'w';
      
      if (isCorner) {
        // Para esquinas: mantener proporción automáticamente usando la proporción inicial
        const initialAspect = startRect.w / startRect.h;
        dynamicConstraints = {
          ...constraints,
          lockAspect: true,
          aspectRatio: initialAspect,
        };
      } else if (isEdge) {
        // Para bordes: no mantener proporción (solo cambiar un lado, el opuesto queda fijo)
        dynamicConstraints = {
          ...constraints,
          lockAspect: false,
        };
        console.debug('[useTransformGestures] Edge resize:', { 
          handle: activeHandle, 
          delta, 
          startSize: { w: startRect.w, h: startRect.h },
          startCenter: { cx: startRect.cx, cy: startRect.cy }
        });
      } else {
        dynamicConstraints = constraints;
      }
    }
    
    // Aplicar transformación
    const newShape = applyTransform(
      startShapeRef.current,
      shapeType,
      activeHandle,
      delta,
      dynamicConstraints,
      startShapeRef.current,
      startMouseLocalRef.current,
      currentLocalPoint
    );
    
    onShapeChange(shapeToOutput(newShape));
  }, [isTransforming, activeHandle, shapeType, constraints, shapeToOutput, onShapeChange, getContainer]);

  // Handler de fin de transformación
  const handlePointerUp = useCallback((e?: PointerEvent) => {
    if (!isTransforming) return;
    
    // Release pointer capture si hay evento
    if (e && shapeElementRef.current) {
      try {
        shapeElementRef.current.releasePointerCapture(e.pointerId);
      } catch (err) {
        // Ignorar errores si el elemento ya no existe
      }
    }
    
    setActiveHandle(null);
    setIsTransforming(false);
    startShapeRef.current = null;
    startMouseRef.current = null;
    startMouseLocalRef.current = null;
    shapeElementRef.current = null;
    scaleRef.current = 1.0;
    
    onTransformEnd?.();
  }, [isTransforming, onTransformEnd]);

  // Efecto para manejar eventos globales
  useEffect(() => {
    if (!isTransforming) return;
    
    const handleGlobalMove = (e: PointerEvent) => {
      handlePointerMove(e);
    };
    
    const handleGlobalUp = (e: PointerEvent) => {
      handlePointerUp(e);
    };
    
    const handleGlobalCancel = (e: PointerEvent) => {
      handlePointerUp(e);
    };
    
    window.addEventListener('pointermove', handleGlobalMove);
    window.addEventListener('pointerup', handleGlobalUp);
    window.addEventListener('pointercancel', handleGlobalCancel);
    
    return () => {
      window.removeEventListener('pointermove', handleGlobalMove);
      window.removeEventListener('pointerup', handleGlobalUp);
      window.removeEventListener('pointercancel', handleGlobalCancel);
    };
  }, [isTransforming, handlePointerMove, handlePointerUp]);

  // Handlers para bind
  const bind = {
    onPointerDown: handlePointerDown,
  };
  
  // Función helper para iniciar transformación con handle explícito
  const startTransform = useCallback((
    e: React.PointerEvent,
    handle: TransformHandle,
    element?: HTMLElement
  ) => {
    handlePointerDown(e, element, handle);
  }, [handlePointerDown]);

  // Estado debug (para badge)
  const debugState = isTransforming && startShapeRef.current
    ? (shapeType === 'circle'
        ? {
            x: (startShapeRef.current as CircleLike).cx,
            y: (startShapeRef.current as CircleLike).cy,
            w: (startShapeRef.current as CircleLike).r * 2,
            h: (startShapeRef.current as CircleLike).r * 2,
            rot: 0,
            scale: scaleRef.current,
          }
        : {
            x: (startShapeRef.current as RectLike).cx - (startShapeRef.current as RectLike).w / 2,
            y: (startShapeRef.current as RectLike).cy - (startShapeRef.current as RectLike).h / 2,
            w: (startShapeRef.current as RectLike).w,
            h: (startShapeRef.current as RectLike).h,
            rot: (startShapeRef.current as RectLike).rotation,
            scale: scaleRef.current,
          })
    : null;

  return {
    bind,
    startTransform,
    activeHandle,
    isTransforming,
    debugState,
    constraints,
  };
}

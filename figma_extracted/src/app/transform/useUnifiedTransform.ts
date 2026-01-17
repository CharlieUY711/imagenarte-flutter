/**
 * HOOK UNIFICADO DE TRANSFORMACIÓN
 * 
 * Maneja gestos de pointer para transformar formas usando el sistema canónico.
 * Reutilizable para máscaras, watermarks, textos y logos.
 */

import { useState, useRef, useEffect, useCallback } from 'react';
import { getLocalPoint, getScaleFactor } from '../../utils/pointer';
import {
  hitTestCircle,
  hitTestQuad,
  type CircleShape,
  type QuadShape,
  type TransformMode,
} from './unifiedHitTest';
import {
  applyMoveCircle,
  applyResizeCircle,
  applyMoveQuad,
  applyResizeQuadProportional,
  applyResizeQuadAxis,
  type TransformConstraints,
} from './unifiedTransform';

// ============================================================================
// TIPOS
// ============================================================================

export type ShapeType = 'circle' | 'quad';

export interface CircleInput {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface QuadInput {
  x: number;
  y: number;
  width: number;
  height: number;
}

export type ShapeInput = CircleInput | QuadInput;

export interface UseUnifiedTransformOptions {
  shape: ShapeInput;
  shapeType: ShapeType;
  onShapeChange: (shape: ShapeInput) => void;
  constraints?: TransformConstraints;
  onTransformStart?: () => void;
  onTransformEnd?: () => void;
  containerRef?: React.RefObject<HTMLElement>;
  containerSelector?: string;
}

// ============================================================================
// CONVERSIONES
// ============================================================================

function circleInputToShape(input: CircleInput): CircleShape {
  return {
    cx: input.x + input.width / 2,
    cy: input.y + input.height / 2,
    r: Math.min(input.width, input.height) / 2,
  };
}

function circleShapeToInput(shape: CircleShape): CircleInput {
  const diameter = shape.r * 2;
  return {
    x: shape.cx - shape.r,
    y: shape.cy - shape.r,
    width: diameter,
    height: diameter,
  };
}

function quadInputToShape(input: QuadInput): QuadShape {
  return {
    x: input.x,
    y: input.y,
    w: input.width,
    h: input.height,
  };
}

function quadShapeToInput(shape: QuadShape): QuadInput {
  return {
    x: shape.x,
    y: shape.y,
    width: shape.w,
    height: shape.h,
  };
}

// ============================================================================
// HOOK PRINCIPAL
// ============================================================================

export function useUnifiedTransform({
  shape,
  shapeType,
  onShapeChange,
  constraints,
  onTransformStart,
  onTransformEnd,
  containerRef: externalContainerRef,
  containerSelector = '.preview-image-container',
}: UseUnifiedTransformOptions) {
  const [activeMode, setActiveMode] = useState<TransformMode | null>(null);
  const [isTransforming, setIsTransforming] = useState(false);
  
  const startShapeRef = useRef<CircleShape | QuadShape | null>(null);
  const startMouseRef = useRef<{ x: number; y: number } | null>(null);
  const activeCornerRef = useRef<'nw' | 'ne' | 'sw' | 'se' | null>(null);
  const activeSideRef = useRef<'n' | 's' | 'e' | 'w' | null>(null);
  const containerElementRef = useRef<HTMLElement | null>(null);
  const scaleRef = useRef<number>(1.0);
  
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
  
  // Detectar zona activa desde coordenadas del puntero
  const detectZone = useCallback((
    localX: number,
    localY: number
  ): TransformMode => {
    if (shapeType === 'circle') {
      const circleShape = circleInputToShape(shape as CircleInput);
      return hitTestCircle(localX, localY, circleShape);
    } else {
      const quadShape = quadInputToShape(shape as QuadInput);
      return hitTestQuad(localX, localY, quadShape);
    }
  }, [shape, shapeType]);
  
  // Detectar esquina o lado activo para quads
  const detectQuadCornerOrSide = useCallback((
    localX: number,
    localY: number,
    quad: QuadShape
  ): { corner: 'nw' | 'ne' | 'sw' | 'se' | null; side: 'n' | 's' | 'e' | 'w' | null } => {
    const relX = localX - quad.x;
    const relY = localY - quad.y;
    const cornerSize = Math.min(quad.w, quad.h) * 0.05;
    
    // Detectar esquina más cercana
    const distFromNW = Math.hypot(relX - 0, relY - 0);
    const distFromNE = Math.hypot(relX - quad.w, relY - 0);
    const distFromSW = Math.hypot(relX - 0, relY - quad.h);
    const distFromSE = Math.hypot(relX - quad.w, relY - quad.h);
    
    let corner: 'nw' | 'ne' | 'sw' | 'se' | null = null;
    if (distFromNW < cornerSize) corner = 'nw';
    else if (distFromNE < cornerSize) corner = 'ne';
    else if (distFromSW < cornerSize) corner = 'sw';
    else if (distFromSE < cornerSize) corner = 'se';
    
    // Detectar lado
    let side: 'n' | 's' | 'e' | 'w' | null = null;
    if (!corner) {
      const EDGE_T = 12;
      if (relY < EDGE_T && relX > cornerSize && relX < quad.w - cornerSize) side = 'n';
      else if (relY > quad.h - EDGE_T && relX > cornerSize && relX < quad.w - cornerSize) side = 's';
      else if (relX < EDGE_T && relY > cornerSize && relY < quad.h - cornerSize) side = 'w';
      else if (relX > quad.w - EDGE_T && relY > cornerSize && relY < quad.h - cornerSize) side = 'e';
    }
    
    return { corner, side };
  }, []);
  
  // Handler de inicio de transformación
  const handlePointerDown = useCallback((
    e: React.PointerEvent,
    element?: HTMLElement
  ) => {
    e.stopPropagation();
    
    const containerElement = getContainer();
    if (!containerElement) {
      console.warn('useUnifiedTransform: No se encontró contenedor');
      return;
    }
    
    const scale = getScaleFactor(containerElement);
    scaleRef.current = scale;
    
    const localPoint = getLocalPoint(e, containerElement);
    const mode = detectZone(localPoint.x, localPoint.y);
    
    if (!mode) return;
    
    // Guardar snapshot inicial
    if (shapeType === 'circle') {
      startShapeRef.current = circleInputToShape(shape as CircleInput);
    } else {
      const quadShape = quadInputToShape(shape as QuadInput);
      startShapeRef.current = quadShape;
      
      // Para quads, detectar esquina o lado si es resize
      if (mode === 'resize-proportional' || mode === 'resize-axis') {
        const { corner, side } = detectQuadCornerOrSide(localPoint.x, localPoint.y, quadShape);
        activeCornerRef.current = corner;
        activeSideRef.current = side;
      }
    }
    
    startMouseRef.current = localPoint;
    setActiveMode(mode);
    setIsTransforming(true);
    
    onTransformStart?.();
    
    // Pointer capture
    try {
      (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    } catch (err) {
      console.warn('setPointerCapture failed:', err);
    }
  }, [shape, shapeType, detectZone, detectQuadCornerOrSide, getContainer, onTransformStart]);
  
  // Handler de movimiento durante transformación
  const handlePointerMove = useCallback((e: PointerEvent) => {
    if (!isTransforming || !activeMode || !startShapeRef.current || !startMouseRef.current) {
      return;
    }
    
    const containerElement = getContainer();
    if (!containerElement) return;
    
    const currentLocalPoint = getLocalPoint(e, containerElement);
    
    if (shapeType === 'circle') {
      const startCircle = startShapeRef.current as CircleShape;
      
      if (activeMode === 'move') {
        const deltaX = (currentLocalPoint.x - startMouseRef.current.x) / scaleRef.current;
        const deltaY = (currentLocalPoint.y - startMouseRef.current.y) / scaleRef.current;
        const newCircle = applyMoveCircle(startCircle, deltaX, deltaY, constraints);
        onShapeChange(circleShapeToInput(newCircle));
      } else if (activeMode === 'resize-proportional') {
        const newCircle = applyResizeCircle(
          startCircle,
          startCircle,
          currentLocalPoint.x,
          currentLocalPoint.y,
          constraints
        );
        onShapeChange(circleShapeToInput(newCircle));
      }
    } else {
      const startQuad = startShapeRef.current as QuadShape;
      
      if (activeMode === 'move') {
        const deltaX = (currentLocalPoint.x - startMouseRef.current.x) / scaleRef.current;
        const deltaY = (currentLocalPoint.y - startMouseRef.current.y) / scaleRef.current;
        const newQuad = applyMoveQuad(startQuad, deltaX, deltaY, constraints);
        onShapeChange(quadShapeToInput(newQuad));
      } else if (activeMode === 'resize-proportional' && activeCornerRef.current) {
        const newQuad = applyResizeQuadProportional(
          startQuad,
          startQuad,
          activeCornerRef.current,
          currentLocalPoint.x,
          currentLocalPoint.y,
          constraints
        );
        onShapeChange(quadShapeToInput(newQuad));
      } else if (activeMode === 'resize-axis' && activeSideRef.current) {
        const newQuad = applyResizeQuadAxis(
          startQuad,
          startQuad,
          activeSideRef.current,
          currentLocalPoint.x,
          currentLocalPoint.y,
          constraints
        );
        onShapeChange(quadShapeToInput(newQuad));
      }
    }
  }, [isTransforming, activeMode, shapeType, constraints, onShapeChange, getContainer]);
  
  // Handler de fin de transformación
  const handlePointerUp = useCallback((e?: PointerEvent) => {
    if (!isTransforming) return;
    
    if (e && e.currentTarget) {
      try {
        (e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId);
      } catch (err) {
        // Ignorar errores
      }
    }
    
    setActiveMode(null);
    setIsTransforming(false);
    startShapeRef.current = null;
    startMouseRef.current = null;
    activeCornerRef.current = null;
    activeSideRef.current = null;
    
    onTransformEnd?.();
  }, [isTransforming, onTransformEnd]);
  
  // Efecto para eventos globales
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
  
  // Calcular modo activo para hover (sin transformar)
  const calculateHoverMode = useCallback((
    localX: number,
    localY: number
  ): TransformMode => {
    if (isTransforming) return activeMode;
    return detectZone(localX, localY);
  }, [isTransforming, activeMode, detectZone]);
  
  return {
    bind: {
      onPointerDown: handlePointerDown,
    },
    activeMode,
    isTransforming,
    calculateHoverMode,
  };
}

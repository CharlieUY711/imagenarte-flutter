/**
 * Overlay de círculo transformable con sistema unificado
 * 
 * Usa el sistema canónico de hit-test y transformación.
 * Solo muestra icono central (no handles visibles).
 */

import { useRef, useState, useCallback } from 'react';
import { useUnifiedTransform, type CircleInput } from '../../app/transform/useUnifiedTransform';
import { CenterIcon } from '../../app/components/CenterIcon';
import { getLocalPoint } from '../../utils/pointer';

export interface CircleTransformOverlayProps {
  /** Forma del círculo (en formato { x, y, width, height }) */
  shape: CircleInput;
  /** Callback cuando la forma cambia */
  onShapeChange: (shape: CircleInput) => void;
  /** Restricciones de transformación */
  constraints?: {
    bounds?: {
      minX: number;
      minY: number;
      maxX: number;
      maxY: number;
    };
    minSize?: { radius?: number };
    maxSize?: { radius?: number };
  };
  /** Ref del contenedor para calcular coordenadas locales */
  containerRef?: React.RefObject<HTMLElement>;
  /** Callback opcional cuando comienza una transformación */
  onTransformStart?: () => void;
  /** Callback opcional cuando termina una transformación */
  onTransformEnd?: () => void;
}

/**
 * Overlay de círculo transformable con MOVE + RESIZE
 */
export function CircleTransformOverlay({
  shape,
  onShapeChange,
  constraints,
  containerRef,
  onTransformStart,
  onTransformEnd,
}: CircleTransformOverlayProps) {
  const elementRef = useRef<HTMLDivElement>(null);
  const [hoverMode, setHoverMode] = useState<'move' | 'resize' | null>(null);
  
  // Hook unificado de transformación
  const transform = useUnifiedTransform({
    shape,
    shapeType: 'circle',
    onShapeChange,
    constraints: constraints ? {
      bounds: constraints.bounds,
      minSize: constraints.minSize ? { radius: constraints.minSize.radius } : undefined,
      maxSize: constraints.maxSize ? { radius: constraints.maxSize.radius } : undefined,
    } : undefined,
    containerRef,
    onTransformStart,
    onTransformEnd,
  });
  
  // Calcular modo de hover
  const handleMouseMove = useCallback((e: React.MouseEvent) => {
    if (transform.isTransforming) return;
    
    const containerElement = containerRef?.current || document.querySelector('.preview-image-container') as HTMLElement;
    if (!containerElement) return;
    
    const localPoint = getLocalPoint(e, containerElement);
    const mode = transform.calculateHoverMode(localPoint.x, localPoint.y);
    
    if (mode === 'move') {
      setHoverMode('move');
    } else if (mode === 'resize-proportional') {
      setHoverMode('resize');
    } else {
      setHoverMode(null);
    }
  }, [transform, containerRef]);
  
  const handleMouseLeave = useCallback(() => {
    if (!transform.isTransforming) {
      setHoverMode(null);
    }
  }, [transform.isTransforming]);
  
  // Determinar modo activo (hover o transformando)
  const activeMode = transform.isTransforming
    ? (transform.activeMode === 'move' ? 'move' : 'resize')
    : hoverMode;
  
  return (
    <div
      ref={elementRef}
      className="absolute pointer-events-auto touch-action-none"
      style={{
        left: `${shape.x}px`,
        top: `${shape.y}px`,
        width: `${shape.width}px`,
        height: `${shape.height}px`,
        zIndex: 10,
        cursor: transform.isTransforming
          ? 'grabbing'
          : hoverMode === 'resize'
          ? 'nwse-resize'
          : hoverMode === 'move'
          ? 'move'
          : 'default',
      }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      {...transform.bind}
      onClick={(e) => {
        e.stopPropagation();
      }}
    >
      {/* Outline del círculo visual */}
      <div
        className="w-full h-full border-2 border-orange-500 bg-orange-500/10 rounded-full pointer-events-none"
      />
      
      {/* ÍCONO ÚNICO CENTRAL (relativo al elemento) */}
      {activeMode && (
        <CenterIcon
          mode={activeMode}
          x={shape.width / 2}
          y={shape.height / 2}
          size={24}
        />
      )}
    </div>
  );
}

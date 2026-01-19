/**
 * Overlay de recorte con sistema unificado de transformación
 * 
 * Usa el sistema canónico de hit-test y transformación.
 * Soporta círculos y cuadriláteros (sin rotación).
 */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { useUnifiedTransform, type CircleInput, type QuadInput } from '../transform/useUnifiedTransform';
import { CenterIcon } from './CenterIcon';
import { getLocalPoint } from '../../utils/pointer';

type DimensionType = 'vertical' | 'square' | 'landscape' | 'circular' | null;

interface CropOverlayProps {
  dimension: DimensionType;
  containerWidth: number;
  containerHeight: number;
  imageWidth?: number;
  imageHeight?: number;
  onSelectionChange?: (selection: { width: number; height: number }) => void;
  externalDimensions?: { width: number; height: number } | null;
  containerRef?: React.RefObject<HTMLElement>;
}

export function CropOverlay({
  dimension,
  containerWidth,
  containerHeight,
  imageWidth,
  imageHeight,
  onSelectionChange,
  externalDimensions,
  containerRef: externalContainerRef,
}: CropOverlayProps) {
  const isCircular = dimension === 'circular';
  
  // Calcular tamaño y posición iniciales
  const calculateSizeAndPosition = useCallback(() => {
    if (!containerWidth || !containerHeight || containerWidth === 0 || containerHeight === 0 || !dimension) {
      return { width: 200, height: 200, x: 0, y: 0 };
    }

    let newWidth = 200;
    let newHeight = 200;
    let aspectRatio = 1;

    if (imageWidth && imageHeight && imageWidth > 0 && imageHeight > 0) {
      aspectRatio = imageWidth / imageHeight;
    }

    if (dimension === 'vertical') {
      let verticalAspectRatio = 0.75;
      if (imageWidth && imageHeight && imageWidth > 0 && imageHeight > 0 && aspectRatio < 1) {
        verticalAspectRatio = aspectRatio;
      }
      const containerAspectRatio = containerWidth / containerHeight;
      if (verticalAspectRatio > containerAspectRatio) {
        newWidth = containerWidth * 0.9;
        newHeight = newWidth / verticalAspectRatio;
      } else {
        newHeight = containerHeight * 0.9;
        newWidth = newHeight * verticalAspectRatio;
      }
    } else if (dimension === 'landscape') {
      const landscapeAspectRatio = 1.33;
      const containerAspectRatio = containerWidth / containerHeight;
      if (landscapeAspectRatio > containerAspectRatio) {
        newWidth = containerWidth * 0.9;
        newHeight = newWidth / landscapeAspectRatio;
      } else {
        newHeight = containerHeight * 0.9;
        newWidth = newHeight * landscapeAspectRatio;
      }
    } else if (dimension === 'square') {
      newWidth = Math.min(containerWidth * 0.8, containerHeight * 0.8, 400);
      newHeight = newWidth;
    } else if (dimension === 'circular') {
      newWidth = Math.min(containerWidth * 0.6, containerHeight * 0.6, 300);
      newHeight = newWidth;
    }

    newWidth = Math.max(50, Math.min(newWidth, containerWidth));
    newHeight = Math.max(50, Math.min(newHeight, containerHeight));

    const x = (containerWidth - newWidth) / 2;
    const y = (containerHeight - newHeight) / 2;

    return { width: newWidth, height: newHeight, x, y };
  }, [dimension, containerWidth, containerHeight, imageWidth, imageHeight]);

  const initial = calculateSizeAndPosition();
  const [position, setPosition] = useState({ x: initial.x, y: initial.y });
  const [size, setSize] = useState({ width: initial.width, height: initial.height });
  const [hoverMode, setHoverMode] = useState<'move' | 'resize' | null>(null);
  
  const internalContainerRef = useRef<HTMLDivElement>(null);
  const containerRefForTransform = externalContainerRef || (internalContainerRef as React.RefObject<HTMLElement>);
  
  // Forma actual (circle o quad)
  const currentShape: CircleInput | QuadInput = isCircular
    ? { x: position.x, y: position.y, width: size.width, height: size.height }
    : { x: position.x, y: position.y, width: size.width, height: size.height };
  
  // Hook unificado de transformación
  const transform = useUnifiedTransform({
    shape: currentShape,
    shapeType: isCircular ? 'circle' : 'quad',
    onShapeChange: (newShape) => {
      setPosition({ x: newShape.x, y: newShape.y });
      setSize({ width: newShape.width, height: newShape.height });
    },
    constraints: {
      bounds: {
        minX: 0,
        minY: 0,
        maxX: containerWidth,
        maxY: containerHeight,
      },
      minSize: {
        width: 50,
        height: 50,
        radius: 25,
      },
    },
    containerRef: containerRefForTransform,
  });
  
  // Calcular modo de hover
  const handleMouseMove = useCallback((e: React.MouseEvent) => {
    if (transform.isTransforming) return;
    
    const containerElement = containerRefForTransform?.current || document.querySelector('.preview-image-container') as HTMLElement;
    if (!containerElement) return;
    
    const localPoint = getLocalPoint(e, containerElement);
    const mode = transform.calculateHoverMode(localPoint.x, localPoint.y);
    
    if (mode === 'move') {
      setHoverMode('move');
    } else if (mode === 'resize-proportional' || mode === 'resize-axis') {
      setHoverMode('resize');
    } else {
      setHoverMode(null);
    }
  }, [transform, containerRefForTransform]);
  
  const handleMouseLeave = useCallback(() => {
    if (!transform.isTransforming) {
      setHoverMode(null);
    }
  }, [transform.isTransforming]);
  
  // Recalcular tamaño y posición cuando cambien las dimensiones
  useEffect(() => {
    if (externalDimensions && containerWidth > 0 && containerHeight > 0 && imageWidth && imageHeight) {
      const screenWidth = (externalDimensions.width / imageWidth) * containerWidth;
      const screenHeight = (externalDimensions.height / imageHeight) * containerHeight;
      const newX = (containerWidth - screenWidth) / 2;
      const newY = (containerHeight - screenHeight) / 2;
      setSize({ width: screenWidth, height: screenHeight });
      setPosition({ x: newX, y: newY });
    } else {
      const calculated = calculateSizeAndPosition();
      setSize({ width: calculated.width, height: calculated.height });
      setPosition({ x: calculated.x, y: calculated.y });
    }
  }, [dimension, containerWidth, containerHeight, imageWidth, imageHeight, externalDimensions, calculateSizeAndPosition]);

  // Notificar cambios en la selección
  useEffect(() => {
    if (onSelectionChange && containerWidth > 0 && containerHeight > 0 && imageWidth && imageHeight && size.width > 0 && size.height > 0) {
      const selectionWidthReal = Math.round((size.width / containerWidth) * imageWidth);
      const selectionHeightReal = Math.round((size.height / containerHeight) * imageHeight);
      onSelectionChange({ width: selectionWidthReal, height: selectionHeightReal });
    }
  }, [size, containerWidth, containerHeight, imageWidth, imageHeight, onSelectionChange]);

  // Generar ID único para la máscara SVG
  const maskId = `crop-mask-${Math.random().toString(36).substr(2, 9)}`;
  
  // Calcular centro (para máscara SVG, absoluto al contenedor)
  const centerX = position.x + size.width / 2;
  const centerY = position.y + size.height / 2;
  
  // Determinar modo activo
  const activeMode = transform.isTransforming
    ? (transform.activeMode === 'move' ? 'move' : 'resize')
    : hoverMode;

  return (
    <div
      ref={internalContainerRef}
      className="absolute inset-0"
      style={{
        width: '100%',
        height: '100%',
        pointerEvents: 'auto',
      }}
    >
      {/* Overlay con máscara SVG */}
      <svg
        className="absolute inset-0 pointer-events-none"
        style={{ width: '100%', height: '100%' }}
      >
        <defs>
          <mask id={maskId}>
            <rect width="100%" height="100%" fill="white" />
            {isCircular ? (
              <circle
                cx={centerX}
                cy={centerY}
                r={Math.min(size.width, size.height) / 2}
                fill="black"
              />
            ) : (
              <rect
                x={position.x}
                y={position.y}
                width={size.width}
                height={size.height}
                fill="black"
              />
            )}
          </mask>
        </defs>
        <rect
          width="100%"
          height="100%"
          fill="rgba(0, 0, 0, 0.7)"
          mask={`url(#${maskId})`}
        />
      </svg>

      {/* Área de recorte interactiva */}
      <div
        className="absolute"
        style={{
          left: `${position.x}px`,
          top: `${position.y}px`,
          width: `${size.width}px`,
          height: `${size.height}px`,
          pointerEvents: 'auto',
          touchAction: 'none',
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
      >
        {/* Borde del área seleccionada */}
        <div
          className={`w-full h-full border-2 border-orange-500 ${
            isCircular ? 'rounded-full' : 'rounded-none'
          }`}
          style={{
            backgroundColor: 'transparent',
            boxShadow: 'none',
            pointerEvents: 'none',
          }}
        />
        
        {/* ÍCONO ÚNICO CENTRAL (relativo al área de recorte) */}
        {activeMode && (
          <CenterIcon
            mode={activeMode}
            x={size.width / 2}
            y={size.height / 2}
            size={24}
          />
        )}
      </div>
    </div>
  );
}

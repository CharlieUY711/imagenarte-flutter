import { useState, useRef, useEffect } from 'react';

/**
 * Overlay para selección libre de área (herramienta pointer)
 * Permite al usuario dibujar un área libre sobre la imagen
 */
interface FreeSelectionOverlayProps {
  containerWidth: number;
  containerHeight: number;
  imageWidth: number;
  imageHeight: number;
  onSelectionComplete: (area: { x: number; y: number; width: number; height: number }) => void;
  onCancel?: () => void;
}

export function FreeSelectionOverlay({
  containerWidth,
  containerHeight,
  imageWidth,
  imageHeight,
  onSelectionComplete,
  onCancel,
}: FreeSelectionOverlayProps) {
  const [isDrawing, setIsDrawing] = useState(false);
  const [startPoint, setStartPoint] = useState<{ x: number; y: number } | null>(null);
  const [currentPoint, setCurrentPoint] = useState<{ x: number; y: number } | null>(null);
  const overlayRef = useRef<HTMLDivElement>(null);

  // Calcular escala entre contenedor e imagen
  const scaleX = imageWidth / containerWidth;
  const scaleY = imageHeight / containerHeight;

  const handlePointerDown = (e: React.PointerEvent) => {
    e.stopPropagation();
    const rect = overlayRef.current?.getBoundingClientRect();
    if (!rect) return;

    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    setIsDrawing(true);
    setStartPoint({ x, y });
    setCurrentPoint({ x, y });
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDrawing || !startPoint) return;

    const rect = overlayRef.current?.getBoundingClientRect();
    if (!rect) return;

    const x = Math.max(0, Math.min(containerWidth, e.clientX - rect.left));
    const y = Math.max(0, Math.min(containerHeight, e.clientY - rect.top));

    setCurrentPoint({ x, y });
  };

  const handlePointerUp = (e: React.PointerEvent) => {
    if (!isDrawing || !startPoint || !currentPoint) return;

    // Calcular área seleccionada
    const x = Math.min(startPoint.x, currentPoint.x);
    const y = Math.min(startPoint.y, currentPoint.y);
    const width = Math.abs(currentPoint.x - startPoint.x);
    const height = Math.abs(currentPoint.y - startPoint.y);

    // Convertir a coordenadas reales de la imagen
    const realX = Math.round(x * scaleX);
    const realY = Math.round(y * scaleY);
    const realWidth = Math.round(width * scaleX);
    const realHeight = Math.round(height * scaleY);

    // Solo completar si hay un área mínima
    if (realWidth > 10 && realHeight > 10) {
      onSelectionComplete({
        x: realX,
        y: realY,
        width: realWidth,
        height: realHeight,
      });
    }

    setIsDrawing(false);
    setStartPoint(null);
    setCurrentPoint(null);
    e.currentTarget.releasePointerCapture(e.pointerId);
  };

  // Calcular área de selección actual
  const selectionArea = startPoint && currentPoint ? {
    x: Math.min(startPoint.x, currentPoint.x),
    y: Math.min(startPoint.y, currentPoint.y),
    width: Math.abs(currentPoint.x - startPoint.x),
    height: Math.abs(currentPoint.y - startPoint.y),
  } : null;

  return (
    <div
      ref={overlayRef}
      className="absolute inset-0 z-30 cursor-crosshair"
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      style={{ touchAction: 'none' }}
    >
      {/* Área de selección */}
      {selectionArea && (
        <>
          {/* Overlay oscuro fuera del área */}
          <div
            className="absolute bg-black/40"
            style={{
              top: 0,
              left: 0,
              width: '100%',
              height: selectionArea.y,
            }}
          />
          <div
            className="absolute bg-black/40"
            style={{
              top: selectionArea.y,
              left: 0,
              width: selectionArea.x,
              height: selectionArea.height,
            }}
          />
          <div
            className="absolute bg-black/40"
            style={{
              top: selectionArea.y,
              left: selectionArea.x + selectionArea.width,
              width: containerWidth - (selectionArea.x + selectionArea.width),
              height: selectionArea.height,
            }}
          />
          <div
            className="absolute bg-black/40"
            style={{
              top: selectionArea.y + selectionArea.height,
              left: 0,
              width: '100%',
              height: containerHeight - (selectionArea.y + selectionArea.height),
            }}
          />

          {/* Borde de selección */}
          <div
            className="absolute border-2 border-orange-500"
            style={{
              left: selectionArea.x,
              top: selectionArea.y,
              width: selectionArea.width,
              height: selectionArea.height,
            }}
          />
        </>
      )}

    </div>
  );
}

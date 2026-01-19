import React, { useRef, useEffect, useState } from 'react';
import { useEditor } from '../context/EditorContext';
import { applyPixelate, createROIMask } from '../utils/pixelate';

interface EditorCanvasProps {
  imageUrl: string;
}

/**
 * Canvas del editor con soporte para pixelado ROI-based
 * 
 * Renderiza la imagen y aplica pixelado solo dentro del ROI activo
 */
export const EditorCanvas: React.FC<EditorCanvasProps> = ({ imageUrl }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const imageRef = useRef<HTMLImageElement | null>(null);
  const [imageLoaded, setImageLoaded] = useState(false);
  
  const {
    activeContext,
    selectionGeometry,
    pixelateIntensity,
    hasValidSelection,
  } = useEditor();

  // Cargar imagen
  useEffect(() => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => {
      imageRef.current = img;
      setImageLoaded(true);
      renderCanvas();
    };
    img.src = imageUrl;
  }, [imageUrl]);

  // Renderizar canvas cuando cambian los parámetros
  useEffect(() => {
    if (imageLoaded) {
      renderCanvas();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [imageLoaded, pixelateIntensity, selectionGeometry, activeContext]);

  const renderCanvas = React.useCallback(() => {
    const canvas = canvasRef.current;
    const img = imageRef.current;
    if (!canvas || !img) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Ajustar tamaño del canvas
    canvas.width = img.width;
    canvas.height = img.height;

    // Dibujar imagen original
    ctx.drawImage(img, 0, 0);

    // Aplicar pixelado si está activo y hay ROI
    if (activeContext === 'action_pixelate' && hasValidSelection && selectionGeometry) {
      applyPixelateToCanvas(ctx, canvas.width, canvas.height);
    }
  }, [activeContext, hasValidSelection, selectionGeometry]);

  const applyPixelateToCanvas = React.useCallback((
    ctx: CanvasRenderingContext2D,
    width: number,
    height: number
  ) => {
    if (!selectionGeometry) return;

    // Obtener datos de imagen
    const imageData = ctx.getImageData(0, 0, width, height);
    const data = imageData.data;

    // Crear máscara ROI
    const mask = createROIMask(width, height, selectionGeometry);

    // Calcular tamaño de bloque (2px a 50px)
    const blockSize = 2 + (pixelateIntensity / 100) * 48;

    // Aplicar pixelado
    const pixelatedData = applyPixelate(data, width, height, blockSize, mask);

    // Crear nueva ImageData y dibujar
    const newImageData = new ImageData(pixelatedData, width, height);
    ctx.putImageData(newImageData, 0, 0);
  }, [selectionGeometry, pixelateIntensity]);

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <canvas
        ref={canvasRef}
        style={{
          maxWidth: '100%',
          maxHeight: '100%',
          display: 'block',
        }}
      />
    </div>
  );
};

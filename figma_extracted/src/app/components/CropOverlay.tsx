import { useState, useRef, useEffect } from 'react';
import { RotateCw, Move } from 'lucide-react';

type DimensionType = 'vertical' | 'square' | 'landscape' | 'circular' | null;

interface CropOverlayProps {
  dimension: DimensionType;
  containerWidth: number;
  containerHeight: number;
  imageWidth?: number;
  imageHeight?: number;
  onSelectionChange?: (selection: { width: number; height: number }) => void;
  externalDimensions?: { width: number; height: number } | null; // Dimensiones externas para sincronizar
}

export function CropOverlay({ dimension, containerWidth, containerHeight, imageWidth, imageHeight, onSelectionChange, externalDimensions }: CropOverlayProps) {
  // Calcular tamaño y posición iniciales
  const calculateSizeAndPosition = () => {
    if (!containerWidth || !containerHeight || containerWidth === 0 || containerHeight === 0 || !dimension) {
      return { width: 200, height: 200, x: 0, y: 0 };
    }

    let newWidth = 200;
    let newHeight = 200;
    let aspectRatio = 1;

    // Si tenemos dimensiones de la imagen, calcular la proporción real
    if (imageWidth && imageHeight && imageWidth > 0 && imageHeight > 0) {
      aspectRatio = imageWidth / imageHeight;
    }

    // Calcular tamaño basándose en la dimensión seleccionada
    if (dimension === 'vertical') {
      // Vertical: más alto que ancho (proporción 3:4)
      // Usar proporción de imagen solo si es vertical, sino usar 3:4 por defecto
      let verticalAspectRatio = 0.75; // 3:4
      if (imageWidth && imageHeight && imageWidth > 0 && imageHeight > 0 && aspectRatio < 1) {
        verticalAspectRatio = aspectRatio; // Usar proporción de imagen si es vertical
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
      // Landscape: más ancho que alto (proporción 4:3)
      // Siempre usar proporción landscape, independientemente de la imagen
      const landscapeAspectRatio = 1.33; // 4:3
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

    // Asegurar que el tamaño sea válido
    newWidth = Math.max(50, Math.min(newWidth, containerWidth));
    newHeight = Math.max(50, Math.min(newHeight, containerHeight));

    // Centrar siempre el recorte
    const x = (containerWidth - newWidth) / 2;
    const y = (containerHeight - newHeight) / 2;

    return { width: newWidth, height: newHeight, x, y };
  };

  const initial = calculateSizeAndPosition();
  const [position, setPosition] = useState({ x: initial.x, y: initial.y });
  const [size, setSize] = useState({ width: initial.width, height: initial.height });
  const [rotation, setRotation] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const [isMoving, setIsMoving] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [isRotating, setIsRotating] = useState(false);
  const [resizeCorner, setResizeCorner] = useState<'top-left' | 'top-right' | 'bottom-left' | 'bottom-right' | null>(null);
  const [resizeEdge, setResizeEdge] = useState<'top' | 'bottom' | 'left' | 'right' | null>(null);
  const [hoverCorner, setHoverCorner] = useState<'top-left' | 'top-right' | 'bottom-left' | 'bottom-right' | null>(null);
  const [hoverEdge, setHoverEdge] = useState<'top' | 'bottom' | 'left' | 'right' | null>(null);
  const [hoverCircleEdge, setHoverCircleEdge] = useState(false);
  const startPosRef = useRef({ x: 0, y: 0 });
  const startMouseRef = useRef({ x: 0, y: 0 });
  const startSizeRef = useRef({ width: 0, height: 0 });
  const startRotationRef = useRef(0);
  const oppositeCornerRef = useRef({ x: 0, y: 0 });

  const isCircular = dimension === 'circular';

  // Recalcular tamaño y posición cuando cambien las dimensiones
  useEffect(() => {
    // Si hay dimensiones externas, usarlas (convertir de píxeles reales a píxeles de pantalla)
    if (externalDimensions && containerWidth > 0 && containerHeight > 0 && imageWidth && imageHeight) {
      const screenWidth = (externalDimensions.width / imageWidth) * containerWidth;
      const screenHeight = (externalDimensions.height / imageHeight) * containerHeight;
      
      // Mantener el centro
      const newX = (containerWidth - screenWidth) / 2;
      const newY = (containerHeight - screenHeight) / 2;
      
      setSize({ width: screenWidth, height: screenHeight });
      setPosition({ x: newX, y: newY });
    } else {
      // Si no hay dimensiones externas, calcular normalmente
      const calculated = calculateSizeAndPosition();
      setSize({ width: calculated.width, height: calculated.height });
      setPosition({ x: calculated.x, y: calculated.y });
    }
  }, [dimension, containerWidth, containerHeight, imageWidth, imageHeight, externalDimensions]);

  // Notificar cambios en la selección para calcular dimensiones reales
  useEffect(() => {
    if (onSelectionChange && containerWidth > 0 && containerHeight > 0 && imageWidth && imageHeight && size.width > 0 && size.height > 0) {
      // Calcular dimensiones reales de la selección en píxeles de la imagen
      const selectionWidthReal = Math.round((size.width / containerWidth) * imageWidth);
      const selectionHeightReal = Math.round((size.height / containerHeight) * imageHeight);
      onSelectionChange({ width: selectionWidthReal, height: selectionHeightReal });
    }
  }, [size, containerWidth, containerHeight, imageWidth, imageHeight, onSelectionChange]);



  // Handler para mover la selección arrastrando sobre ella
  const handleMoveStart = (e: React.PointerEvent) => {
    e.stopPropagation();
    // Asegurar que solo una herramienta funcione a la vez
    if (isResizing || isRotating) return;
    setIsMoving(true);
    startPosRef.current = { ...position };
    startMouseRef.current = { x: e.clientX, y: e.clientY };
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handleMove = (e: PointerEvent) => {
    if (!isMoving) return;
    
    const deltaX = e.clientX - startMouseRef.current.x;
    const deltaY = e.clientY - startMouseRef.current.y;
    
    const newX = Math.max(0, Math.min(containerWidth - size.width, startPosRef.current.x + deltaX));
    const newY = Math.max(0, Math.min(containerHeight - size.height, startPosRef.current.y + deltaY));
    
    setPosition({ x: newX, y: newY });
  };

  const handleMoveEnd = () => {
    setIsMoving(false);
  };

  // Handler para redimensionar desde los bordes
  const handleEdgeResizeStart = (e: React.PointerEvent, edge: 'top' | 'bottom' | 'left' | 'right') => {
    e.stopPropagation();
    // Asegurar que solo una herramienta funcione a la vez
    if (isMoving || isRotating) return;
    setIsResizing(true);
    setResizeEdge(edge);
    startPosRef.current = { ...position };
    startSizeRef.current = { ...size };
    startMouseRef.current = { x: e.clientX, y: e.clientY };
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handleEdgeResize = (e: PointerEvent) => {
    if (!isResizing || !resizeEdge) return;
    
    const deltaX = e.clientX - startMouseRef.current.x;
    const deltaY = e.clientY - startMouseRef.current.y;
    
    let newWidth = startSizeRef.current.width;
    let newHeight = startSizeRef.current.height;
    let newX = startPosRef.current.x;
    let newY = startPosRef.current.y;
    
    // Solo cambiar la dimensión correspondiente al borde
    if (resizeEdge === 'top') {
      // Solo cambia el alto, moviendo hacia arriba
      newHeight = Math.max(50, Math.min(containerHeight - startPosRef.current.y, startSizeRef.current.height - deltaY));
      newY = startPosRef.current.y + (startSizeRef.current.height - newHeight);
    } else if (resizeEdge === 'bottom') {
      // Solo cambia el alto, moviendo hacia abajo
      newHeight = Math.max(50, Math.min(containerHeight - startPosRef.current.y, startSizeRef.current.height + deltaY));
    } else if (resizeEdge === 'left') {
      // Solo cambia el ancho, moviendo hacia la izquierda
      newWidth = Math.max(50, Math.min(containerWidth - startPosRef.current.x, startSizeRef.current.width - deltaX));
      newX = startPosRef.current.x + (startSizeRef.current.width - newWidth);
    } else if (resizeEdge === 'right') {
      // Solo cambia el ancho, moviendo hacia la derecha
      newWidth = Math.max(50, Math.min(containerWidth - startPosRef.current.x, startSizeRef.current.width + deltaX));
    }
    
    // Asegurar que no se salga de los límites
    newX = Math.max(0, Math.min(containerWidth - newWidth, newX));
    newY = Math.max(0, Math.min(containerHeight - newHeight, newY));
    newWidth = Math.min(newWidth, containerWidth - newX);
    newHeight = Math.min(newHeight, containerHeight - newY);
    
    setSize({ width: newWidth, height: newHeight });
    setPosition({ x: newX, y: newY });
  };

  const handleEdgeResizeEnd = () => {
    setIsResizing(false);
    setResizeEdge(null);
  };

  // Handler para redimensionar desde el borde del círculo
  const handleCircleResizeStart = (e: React.PointerEvent) => {
    e.stopPropagation();
    if (isMoving || isRotating) return;
    setIsResizing(true);
    startSizeRef.current = { ...size };
    startMouseRef.current = { x: e.clientX, y: e.clientY };
    
    // Guardar el centro del círculo en coordenadas del viewport
    const containerElement = e.currentTarget.closest('.absolute')?.parentElement as HTMLElement;
    if (containerElement) {
      const containerRect = containerElement.getBoundingClientRect();
      const centerX = containerRect.left + position.x + size.width / 2;
      const centerY = containerRect.top + position.y + size.height / 2;
      oppositeCornerRef.current = { x: centerX, y: centerY };
    }
    
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handleCircleResize = (e: PointerEvent) => {
    if (!isResizing || !isCircular) return;
    
    // Calcular la distancia desde el centro hasta la posición actual del mouse
    const currentDist = Math.sqrt(
      (e.clientX - oppositeCornerRef.current.x) ** 2 + 
      (e.clientY - oppositeCornerRef.current.y) ** 2
    );
    
    // Calcular la distancia inicial (radio del círculo)
    const startRadius = Math.min(startSizeRef.current.width, startSizeRef.current.height) / 2;
    const startDist = startRadius;
    
    // El factor de escala es la relación entre la distancia actual y la inicial
    let scaleFactor = currentDist / startDist;
    
    // Asegurar que el factor de escala sea razonable
    scaleFactor = Math.max(0.1, Math.min(5, scaleFactor));
    
    // Calcular nuevo tamaño manteniendo proporción circular
    let newSize = Math.min(startSizeRef.current.width, startSizeRef.current.height) * scaleFactor;
    newSize = Math.max(50, Math.min(containerWidth, containerHeight, newSize));
    
    const newWidth = newSize;
    const newHeight = newSize;
    
    // Calcular nueva posición para mantener el centro fijo
    const newX = position.x + (size.width - newWidth) / 2;
    const newY = position.y + (size.height - newHeight) / 2;
    
    // Asegurar que no se salga de los límites
    const finalX = Math.max(0, Math.min(containerWidth - newWidth, newX));
    const finalY = Math.max(0, Math.min(containerHeight - newHeight, newY));
    const finalWidth = Math.min(newWidth, containerWidth - finalX);
    const finalHeight = Math.min(newHeight, containerHeight - finalY);
    
    setSize({ width: finalWidth, height: finalHeight });
    setPosition({ x: finalX, y: finalY });
  };

  // Handler para redimensionar desde las esquinas
  const handleResizeStart = (e: React.PointerEvent, corner: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right') => {
    e.stopPropagation();
    // Asegurar que solo una herramienta funcione a la vez
    if (isMoving || isRotating) return;
    setIsResizing(true);
    setResizeCorner(corner);
    startPosRef.current = { ...position };
    startSizeRef.current = { ...size };
    startMouseRef.current = { x: e.clientX, y: e.clientY };
    
    // Guardar la posición inicial de la esquina opuesta en coordenadas del viewport
    const containerElement = e.currentTarget.closest('.absolute')?.parentElement as HTMLElement;
    if (containerElement) {
      const containerRect = containerElement.getBoundingClientRect();
      let oppX = 0;
      let oppY = 0;
      
      if (corner === 'top-left') {
        // Esquina opuesta: bottom-right
        oppX = containerRect.left + position.x + size.width;
        oppY = containerRect.top + position.y + size.height;
      } else if (corner === 'top-right') {
        // Esquina opuesta: bottom-left
        oppX = containerRect.left + position.x;
        oppY = containerRect.top + position.y + size.height;
      } else if (corner === 'bottom-left') {
        // Esquina opuesta: top-right
        oppX = containerRect.left + position.x + size.width;
        oppY = containerRect.top + position.y;
      } else if (corner === 'bottom-right') {
        // Esquina opuesta: top-left
        oppX = containerRect.left + position.x;
        oppY = containerRect.top + position.y;
      }
      
      oppositeCornerRef.current = { x: oppX, y: oppY };
    }
    
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handleResize = (e: PointerEvent) => {
    if (!isResizing || !resizeCorner) return;
    
    // Calcular la proporción original
    const aspectRatio = startSizeRef.current.width / startSizeRef.current.height;
    
    // Calcular la distancia actual desde la esquina opuesta (fija)
    const currentDist = Math.sqrt((e.clientX - oppositeCornerRef.current.x) ** 2 + (e.clientY - oppositeCornerRef.current.y) ** 2);
    const startDist = Math.sqrt(startSizeRef.current.width ** 2 + startSizeRef.current.height ** 2);
    
    // El factor de escala es la relación entre la distancia actual y la inicial
    let scaleFactor = currentDist / startDist;
    
    // Asegurar que el factor de escala sea razonable
    scaleFactor = Math.max(0.1, Math.min(5, scaleFactor));
    
    // Calcular nuevo tamaño manteniendo proporción
    let newWidth = startSizeRef.current.width * scaleFactor;
    let newHeight = startSizeRef.current.height * scaleFactor;
    
    // Mantener proporción según la dimensión seleccionada
    if (dimension === 'square' || dimension === 'circular') {
      const avgSize = (newWidth + newHeight) / 2;
      newWidth = avgSize;
      newHeight = avgSize;
    } else {
      // Mantener la proporción original
      newHeight = newWidth / aspectRatio;
    }
    
    // Limitar tamaño mínimo y máximo
    newWidth = Math.max(50, Math.min(containerWidth, newWidth));
    newHeight = Math.max(50, Math.min(containerHeight, newHeight));
    
    // Calcular nueva posición para mantener la esquina opuesta fija
    let newX = startPosRef.current.x;
    let newY = startPosRef.current.y;
    
    if (resizeCorner === 'top-left') {
      newX = startPosRef.current.x + (startSizeRef.current.width - newWidth);
      newY = startPosRef.current.y + (startSizeRef.current.height - newHeight);
    } else if (resizeCorner === 'top-right') {
      newY = startPosRef.current.y + (startSizeRef.current.height - newHeight);
    } else if (resizeCorner === 'bottom-left') {
      newX = startPosRef.current.x + (startSizeRef.current.width - newWidth);
    }
    // bottom-right no necesita ajustar posición
    
    // Asegurar que no se salga de los límites
    newX = Math.max(0, Math.min(containerWidth - newWidth, newX));
    newY = Math.max(0, Math.min(containerHeight - newHeight, newY));
    newWidth = Math.min(newWidth, containerWidth - newX);
    newHeight = Math.min(newHeight, containerHeight - newY);
    
    setSize({ width: newWidth, height: newHeight });
    setPosition({ x: newX, y: newY });
  };

  const handleResizeEnd = () => {
    setIsResizing(false);
    setResizeCorner(null);
  };

  // Handler para rotar
  const handleRotateStart = (e: React.PointerEvent) => {
    e.stopPropagation();
    // Asegurar que solo una herramienta funcione a la vez
    if (isMoving || isResizing) return;
    setIsRotating(true);
    
    // Si la rotación actual está cerca de 0°, saltar inmediatamente a 15°
    const currentRot = ((rotation % 360) + 360) % 360;
    if (currentRot < 7.5 || currentRot > 352.5) {
      // Está cerca de 0°, saltar a 15°
      setRotation(15);
      startRotationRef.current = 15;
    } else {
      startRotationRef.current = rotation;
    }
    
    // Guardar la posición inicial del mouse en coordenadas del viewport
    startMouseRef.current = { x: e.clientX, y: e.clientY };
    
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handleRotate = (e: PointerEvent) => {
    if (!isRotating) return;
    
    // Obtener el contenedor para calcular las coordenadas relativas
    const containerElement = document.querySelector('.preview-image-container') as HTMLElement;
    if (!containerElement) return;
    
    const containerRect = containerElement.getBoundingClientRect();
    const centerX = containerRect.left + position.x + size.width / 2;
    const centerY = containerRect.top + position.y + size.height / 2;
    
    // Calcular el ángulo desde el centro hasta la posición actual del mouse
    const currentAngle = Math.atan2(e.clientY - centerY, e.clientX - centerX);
    
    // Calcular el ángulo inicial (cuando comenzó el arrastre)
    const startAngle = Math.atan2(startMouseRef.current.y - centerY, startMouseRef.current.x - centerX);
    
    // Calcular la diferencia de ángulo
    let deltaAngle = (currentAngle - startAngle) * (180 / Math.PI);
    
    // Normalizar el ángulo
    if (deltaAngle > 180) deltaAngle -= 360;
    if (deltaAngle < -180) deltaAngle += 360;
    
    let newRotation = startRotationRef.current + deltaAngle;
    
    // Normalizar a rango 0-360
    newRotation = ((newRotation % 360) + 360) % 360;
    
    // Snap fuerte y discreto a múltiplos de 15 grados (15, 30, 45, 60, 75, 90, etc.)
    const snapAngle = 15; // Intervalo de snap
    const snapThreshold = 6; // Zona de captura (grados de tolerancia) - más amplia para mejor captura
    
    // Encontrar el múltiplo de 15 más cercano
    let snappedRotation = Math.round(newRotation / snapAngle) * snapAngle;
    
    // Normalizar el snappedRotation también
    snappedRotation = ((snappedRotation % 360) + 360) % 360;
    
    // Calcular la distancia al ángulo de snap más cercano (considerando ambos lados)
    let distanceToSnap = Math.abs(newRotation - snappedRotation);
    
    // Si la distancia es mayor que 180, considerar el otro lado del círculo
    if (distanceToSnap > 180) {
      distanceToSnap = 360 - distanceToSnap;
    }
    
    // También considerar el siguiente múltiplo de 15 (por si estamos entre dos)
    const nextSnap = snappedRotation >= newRotation 
      ? snappedRotation 
      : ((Math.floor(newRotation / snapAngle) + 1) * snapAngle) % 360;
    const prevSnap = snappedRotation <= newRotation 
      ? snappedRotation 
      : ((Math.ceil(newRotation / snapAngle) - 1) * snapAngle) % 360;
    
    const distToNext = Math.min(Math.abs(newRotation - nextSnap), 360 - Math.abs(newRotation - nextSnap));
    const distToPrev = Math.min(Math.abs(newRotation - prevSnap), 360 - Math.abs(newRotation - prevSnap));
    
    // Usar el múltiplo de 15 más cercano
    if (distToNext < distanceToSnap) {
      snappedRotation = nextSnap;
      distanceToSnap = distToNext;
    } else if (distToPrev < distanceToSnap) {
      snappedRotation = prevSnap;
      distanceToSnap = distToPrev;
    }
    
    // Normalizar el snappedRotation
    snappedRotation = ((snappedRotation % 360) + 360) % 360;
    
    // Aplicar snap directo: si estamos dentro del umbral, saltar inmediatamente al múltiplo de 15
    if (distanceToSnap <= snapThreshold) {
      newRotation = snappedRotation;
    }
    
    // Normalizar nuevamente después del snap
    newRotation = ((newRotation % 360) + 360) % 360;
    
    setRotation(newRotation);
  };

  const handleRotateEnd = () => {
    setIsRotating(false);
  };

  // Handler global para mover/resize/rotar
  useEffect(() => {
    const handleGlobalMove = (e: PointerEvent) => {
      if (isMoving) handleMove(e);
      if (isResizing && resizeCorner) handleResize(e);
      if (isResizing && resizeEdge) handleEdgeResize(e);
      if (isResizing && isCircular && !resizeCorner && !resizeEdge) handleCircleResize(e);
      if (isRotating) handleRotate(e);
    };

    const handleGlobalUp = () => {
      if (isMoving) handleMoveEnd();
      if (isResizing && resizeCorner) handleResizeEnd();
      if (isResizing && resizeEdge) handleEdgeResizeEnd();
      if (isResizing && isCircular && !resizeCorner && !resizeEdge) {
        setIsResizing(false);
      }
      if (isRotating) handleRotateEnd();
    };

    if (isMoving || isResizing || isRotating) {
      window.addEventListener('pointermove', handleGlobalMove);
      window.addEventListener('pointerup', handleGlobalUp);
      return () => {
        window.removeEventListener('pointermove', handleGlobalMove);
        window.removeEventListener('pointerup', handleGlobalUp);
      };
    }
  }, [isMoving, isResizing, isRotating, resizeCorner, resizeEdge, isCircular, position, size, rotation, containerWidth, containerHeight, dimension]);

  // Generar ID único para la máscara SVG
  const maskId = `crop-mask-${Math.random().toString(36).substr(2, 9)}`;
  
  // Calcular el centro de rotación
  const centerX = position.x + size.width / 2;
  const centerY = position.y + size.height / 2;

  return (
    <div 
      className="absolute inset-0 pointer-events-none" 
      style={{ 
        width: '100%', 
        height: '100%',
        left: 0,
        top: 0,
        right: 0,
        bottom: 0
      }}
    >
      {/* Overlay con máscara SVG que rota con la selección */}
      <svg 
        className="absolute inset-0 pointer-events-none" 
        style={{ 
          width: '100%', 
          height: '100%'
        }}
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
                transform={`rotate(${rotation} ${centerX} ${centerY})`}
              />
            ) : (
              <rect
                x={position.x}
                y={position.y}
                width={size.width}
                height={size.height}
                fill="black"
                transform={`rotate(${rotation} ${centerX} ${centerY})`}
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

      {/* Texto del ángulo - sobreimpreso, 40px arriba del centro, siempre horizontal, fijo, independiente */}
      {Math.abs(rotation) > 0.5 && (
        <div
          className="absolute pointer-events-none"
          style={{
            left: `${position.x + size.width / 2}px`,
            top: `${position.y + size.height / 2 - 40}px`,
            transform: 'translate(-50%, -50%)',
            zIndex: 30
          }}
        >
          <span
            className="text-orange-500 font-bold"
            style={{
              fontSize: '18px',
              fontFamily: 'system-ui, -apple-system, sans-serif',
              userSelect: 'none',
              textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
              whiteSpace: 'nowrap'
            }}
          >
            {Math.round(Math.abs(rotation))}°
          </span>
        </div>
      )}

      {/* Área de recorte - mantiene iluminación original (sin overlay) */}
      <div
        className="absolute"
        style={{
          left: `${position.x}px`,
          top: `${position.y}px`,
          width: `${size.width}px`,
          height: `${size.height}px`,
          transform: isCircular ? 'none' : `rotate(${rotation}deg)`,
          transformOrigin: 'center',
          pointerEvents: 'auto',
          cursor: isCircular
            ? (hoverCircleEdge ? 'nwse-resize' : 'move')
            : hoverCorner 
            ? (hoverCorner === 'top-left' || hoverCorner === 'bottom-right' ? 'nwse-resize' : 'nesw-resize')
            : hoverEdge
            ? (hoverEdge === 'top' || hoverEdge === 'bottom' ? 'ns-resize' : 'ew-resize')
            : 'move',
        }}
        onPointerDown={(e) => {
          if (isCircular) {
            // Para círculos, detectar si el click está cerca del borde
            const rect = e.currentTarget.getBoundingClientRect();
            const centerX = rect.left + rect.width / 2;
            const centerY = rect.top + rect.height / 2;
            const clickX = e.clientX;
            const clickY = e.clientY;
            const distanceFromCenter = Math.sqrt(
              (clickX - centerX) ** 2 + (clickY - centerY) ** 2
            );
            const radius = Math.min(size.width, size.height) / 2;
            const edgeThreshold = 12; // Distancia desde el borde para considerar "en el borde"
            
            // Si está cerca del borde, redimensionar; si no, mover
            if (Math.abs(distanceFromCenter - radius) < edgeThreshold) {
              e.stopPropagation();
              handleCircleResizeStart(e);
            } else {
              handleMoveStart(e);
            }
          } else {
            // Para formas rectangulares, solo mover si no está sobre una esquina o borde
            if (!hoverCorner && !hoverEdge) {
              handleMoveStart(e);
            }
          }
        }}
        onMouseMove={(e) => {
          if (isCircular) {
            // Calcular si el mouse está cerca del borde
            const rect = e.currentTarget.getBoundingClientRect();
            const centerX = rect.left + rect.width / 2;
            const centerY = rect.top + rect.height / 2;
            const mouseX = e.clientX;
            const mouseY = e.clientY;
            const distanceFromCenter = Math.sqrt(
              (mouseX - centerX) ** 2 + (mouseY - centerY) ** 2
            );
            const radius = Math.min(size.width, size.height) / 2;
            const edgeThreshold = 12;
            
            setHoverCircleEdge(Math.abs(distanceFromCenter - radius) < edgeThreshold);
          }
        }}
        onMouseLeave={() => {
          if (isCircular) {
            setHoverCircleEdge(false);
          }
        }}
      >
        {/* Borde del área seleccionada */}
        <div
          className={`w-full h-full border-2 border-orange-500 ${
            isCircular ? 'rounded-full' : 'rounded-none'
          }`}
          style={{
            backgroundColor: 'transparent',
            boxShadow: 'none',
          }}
        />

        {/* Icono central - rotar para formas rectangulares, mover para círculos */}
        {!isCircular ? (
          <div 
            className="absolute z-10 pointer-events-none"
            style={{
              left: '50%',
              top: '50%',
              transform: 'translate(-50%, -50%)',
              width: '60px',
              height: '60px'
            }}
          >
            {/* Eje cartesiano rotado punteado naranja (solo cuando se está girando) */}
            {isRotating && (
              <svg 
                width="60"
                height="60"
                viewBox="0 0 60 60"
                className="pointer-events-none"
                style={{ 
                  position: 'absolute',
                  left: '0',
                  top: '0'
                }}
              >
                {/* Eje horizontal (X) rotado */}
                <line
                  x1="0"
                  y1="30"
                  x2="60"
                  y2="30"
                  stroke="#f97316"
                  strokeWidth="1"
                  strokeDasharray="2 2"
                />
                {/* Eje vertical (Y) rotado */}
                <line
                  x1="30"
                  y1="0"
                  x2="30"
                  y2="60"
                  stroke="#f97316"
                  strokeWidth="1"
                  strokeDasharray="2 2"
                />
              </svg>
            )}
            
            {/* Arco mostrando el ángulo entre los ejes (solo cuando se está girando) */}
            {isRotating && Math.abs(rotation) > 0.5 && (
              <svg 
                width="60"
                height="60"
                viewBox="0 0 60 60"
                className="pointer-events-none"
                style={{ 
                  position: 'absolute',
                  left: '0',
                  top: '0'
                }}
              >
                {/* Arco del ángulo */}
                <path
                  d={`M 30 10 A 20 20 0 ${Math.abs(rotation) > 180 ? 1 : 0} ${rotation > 0 ? 1 : 0} ${30 + 20 * Math.sin((rotation * Math.PI) / 180)} ${30 - 20 * Math.cos((rotation * Math.PI) / 180)} L 30 30 Z`}
                  fill="rgba(249, 115, 22, 0.2)"
                  stroke="#f97316"
                  strokeWidth="1"
                />
                {/* Línea desde el centro hasta el punto final del arco */}
                <line
                  x1="30"
                  y1="30"
                  x2={30 + 20 * Math.sin((rotation * Math.PI) / 180)}
                  y2={30 - 20 * Math.cos((rotation * Math.PI) / 180)}
                  stroke="#f97316"
                  strokeWidth="1"
                  strokeDasharray="2 2"
                />
              </svg>
            )}
            
            {/* Icono de rotar centrado en el punto de intersección de los ejes (30, 30) */}
            <button
              onPointerDown={handleRotateStart}
              className="absolute cursor-grab active:cursor-grabbing pointer-events-auto"
              style={{ 
                left: '30px',
                top: '30px',
                transform: 'translate(-50%, -50%)',
                width: '20px',
                height: '20px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: 'transparent',
                border: 'none',
                padding: '0'
              }}
            >
              <RotateCw className="w-5 h-5 text-white hover:text-orange-500 transition-colors" />
            </button>
          </div>
        ) : (
          <div 
            className="absolute z-10 pointer-events-none"
            style={{
              left: '50%',
              top: '50%',
              transform: 'translate(-50%, -50%)',
              width: '60px',
              height: '60px'
            }}
          >
            {/* Icono de mover (cuatro flechas) centrado */}
            <div
              className="absolute cursor-move pointer-events-auto"
              style={{ 
                left: '30px',
                top: '30px',
                transform: 'translate(-50%, -50%)',
                width: '20px',
                height: '20px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Move className="w-5 h-5 text-white hover:text-orange-500 transition-colors" />
            </div>
          </div>
        )}

        {/* Áreas interactivas en las esquinas para redimensionar */}
        {!isCircular && (
          <>
            {/* Esquina superior izquierda - 5% del lado desde la esquina */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleResizeStart(e, 'top-left');
              }}
              onMouseEnter={() => {
                setHoverCorner('top-left');
                setHoverEdge(null);
              }}
              onMouseLeave={() => setHoverCorner(null)}
              className="absolute top-0 left-0 cursor-nwse-resize z-10"
              style={{ 
                touchAction: 'none',
                width: `${Math.max(10, size.width * 0.05)}px`,
                height: `${Math.max(10, size.height * 0.05)}px`,
                marginTop: '-4px',
                marginLeft: '-4px'
              }}
            />
            
            {/* Esquina superior derecha - 5% del lado desde la esquina */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleResizeStart(e, 'top-right');
              }}
              onMouseEnter={() => {
                setHoverCorner('top-right');
                setHoverEdge(null);
              }}
              onMouseLeave={() => setHoverCorner(null)}
              className="absolute top-0 right-0 cursor-nesw-resize z-10"
              style={{ 
                touchAction: 'none',
                width: `${Math.max(10, size.width * 0.05)}px`,
                height: `${Math.max(10, size.height * 0.05)}px`,
                marginTop: '-4px',
                marginRight: '-4px'
              }}
            />
            
            {/* Esquina inferior izquierda - 5% del lado desde la esquina */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleResizeStart(e, 'bottom-left');
              }}
              onMouseEnter={() => {
                setHoverCorner('bottom-left');
                setHoverEdge(null);
              }}
              onMouseLeave={() => setHoverCorner(null)}
              className="absolute bottom-0 left-0 cursor-nesw-resize z-10"
              style={{ 
                touchAction: 'none',
                width: `${Math.max(10, size.width * 0.05)}px`,
                height: `${Math.max(10, size.height * 0.05)}px`,
                marginBottom: '-4px',
                marginLeft: '-4px'
              }}
            />
            
            {/* Esquina inferior derecha - 5% del lado desde la esquina */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleResizeStart(e, 'bottom-right');
              }}
              onMouseEnter={() => {
                setHoverCorner('bottom-right');
                setHoverEdge(null);
              }}
              onMouseLeave={() => setHoverCorner(null)}
              className="absolute bottom-0 right-0 cursor-nwse-resize z-10"
              style={{ 
                touchAction: 'none',
                width: `${Math.max(10, size.width * 0.05)}px`,
                height: `${Math.max(10, size.height * 0.05)}px`,
                marginBottom: '-4px',
                marginRight: '-4px'
              }}
            />
            
            {/* Borde superior - 90% central, cambia solo el alto */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleEdgeResizeStart(e, 'top');
              }}
              onMouseEnter={() => {
                setHoverEdge('top');
                setHoverCorner(null);
              }}
              onMouseLeave={() => setHoverEdge(null)}
              className="absolute top-0 cursor-ns-resize z-10"
              style={{ 
                touchAction: 'none',
                left: `${Math.max(10, size.width * 0.05)}px`,
                right: `${Math.max(10, size.width * 0.05)}px`,
                height: '8px',
                marginTop: '-4px'
              }}
            />
            
            {/* Borde inferior - 90% central, cambia solo el alto */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleEdgeResizeStart(e, 'bottom');
              }}
              onMouseEnter={() => {
                setHoverEdge('bottom');
                setHoverCorner(null);
              }}
              onMouseLeave={() => setHoverEdge(null)}
              className="absolute bottom-0 cursor-ns-resize z-10"
              style={{ 
                touchAction: 'none',
                left: `${Math.max(10, size.width * 0.05)}px`,
                right: `${Math.max(10, size.width * 0.05)}px`,
                height: '8px',
                marginBottom: '-4px'
              }}
            />
            
            {/* Borde izquierdo - 90% central, cambia solo el ancho */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleEdgeResizeStart(e, 'left');
              }}
              onMouseEnter={() => {
                setHoverEdge('left');
                setHoverCorner(null);
              }}
              onMouseLeave={() => setHoverEdge(null)}
              className="absolute left-0 cursor-ew-resize z-10"
              style={{ 
                touchAction: 'none',
                top: `${Math.max(10, size.height * 0.05)}px`,
                bottom: `${Math.max(10, size.height * 0.05)}px`,
                width: '8px',
                marginLeft: '-4px'
              }}
            />
            
            {/* Borde derecho - 90% central, cambia solo el ancho */}
            <div
              onPointerDown={(e) => {
                e.stopPropagation();
                handleEdgeResizeStart(e, 'right');
              }}
              onMouseEnter={() => {
                setHoverEdge('right');
                setHoverCorner(null);
              }}
              onMouseLeave={() => setHoverEdge(null)}
              className="absolute right-0 cursor-ew-resize z-10"
              style={{ 
                touchAction: 'none',
                top: `${Math.max(10, size.height * 0.05)}px`,
                bottom: `${Math.max(10, size.height * 0.05)}px`,
                width: '8px',
                marginRight: '-4px'
              }}
            />
          </>
        )}

        {/* Área interactiva en el borde del círculo para redimensionar - solo visual, la lógica está en el área principal */}

      </div>
    </div>
  );
}

import { useState, useRef, useEffect, useCallback } from 'react';
import { Move, RotateCw, Maximize2, Minimize2 } from 'lucide-react';
import { useTransformGestures, RectInput, CircleInput } from '../transform/useTransformGestures';
import { TransformHandle, applyTransform, positionSizeToRect, rectToPositionSize, positionSizeToCircle, circleToPositionSize } from '../transform/transformEngine';

/**
 * Playground para probar transformaciones (move/resize/rotate)
 * 
 * Acceso: localhost:5178/transform-playground (o toggle en UI)
 */
export function TransformPlayground() {
  const containerRef = useRef<HTMLDivElement>(null);
  
  // Estado para rectángulo
  const [rectShape, setRectShape] = useState<RectInput>({
    x: 150,
    y: 150,
    width: 200,
    height: 150,
    rotation: 0,
  });
  
  // Estado para círculo
  const [circleShape, setCircleShape] = useState<CircleInput>({
    x: 400,
    y: 200,
    width: 150,
    height: 150,
  });
  
  // Hook de transformación para rectángulo
  const rectTransform = useTransformGestures({
    shape: rectShape,
    shapeType: 'rect',
    onShapeChange: (shape) => setRectShape(shape as RectInput),
    constraints: {
      bounds: {
        minX: 0,
        minY: 0,
        maxX: 800,
        maxY: 600,
      },
      minSize: { width: 50, height: 50 },
      // Para esquinas, mantener proporción automáticamente
      lockAspect: false, // Se configurará dinámicamente según el handle
    },
    containerRef,
    onTransformStart: () => {
      console.debug('[Transform] Rect: transform start');
    },
    onTransformEnd: () => {
      console.debug('[Transform] Rect: transform end', rectShape);
    },
  });
  
  // Hook de transformación para círculo
  const circleTransform = useTransformGestures({
    shape: circleShape,
    shapeType: 'circle',
    onShapeChange: (shape) => setCircleShape(shape as CircleInput),
    constraints: {
      bounds: {
        minX: 0,
        minY: 0,
        maxX: 800,
        maxY: 600,
      },
      minSize: { radius: 25 },
    },
    containerRef,
    onTransformStart: () => {
      console.debug('[Transform] Circle: transform start');
    },
    onTransformEnd: () => {
      console.debug('[Transform] Circle: transform end', circleShape);
    },
  });
  
  // Badge de debug - mostrar estado actual de la forma activa
  const getDebugState = () => {
    if (rectTransform.isTransforming) {
      return {
        handle: rectTransform.activeHandle,
        x: rectShape.x,
        y: rectShape.y,
        w: rectShape.width,
        h: rectShape.height,
        rot: rectShape.rotation || 0,
        scale: rectTransform.debugState?.scale || 1.0,
      };
    }
    if (circleTransform.isTransforming) {
      return {
        handle: circleTransform.activeHandle,
        x: circleShape.x,
        y: circleShape.y,
        w: circleShape.width,
        h: circleShape.height,
        rot: 0,
        scale: circleTransform.debugState?.scale || 1.0,
      };
    }
    return null;
  };
  
  const activeDebug = getDebugState();
  
  // Estado para saber qué forma está seleccionada
  const [selectedShape, setSelectedShape] = useState<'rect' | 'circle' | null>(null);
  // Estado para saber qué acción está activa en el centro del rectángulo
  const [rectCenterAction, setRectCenterAction] = useState<'move' | 'rotate' | null>(null);
  // Estado para saber si el círculo está en modo resize (hover en el borde)
  const [circleIsResizing, setCircleIsResizing] = useState(false);
  // Estado para saber si el rectángulo está en modo resize (hover en bordes/esquinas)
  const [rectIsResizing, setRectIsResizing] = useState(false);
  // Estado para saber qué handle de resize está activo en el rectángulo
  const [rectResizeHandle, setRectResizeHandle] = useState<TransformHandle | null>(null);
  
  // Manejo de teclado para transformaciones incrementales
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Solo procesar si no estamos escribiendo en un input
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
        return;
      }
      
      // Determinar el paso según la tecla presionada
      const isTab = e.key === 'Tab';
      const step = isTab ? 15 : 1; // Tab: 15 unidades, flechas: 1 unidad
      const rotationStep = isTab ? 15 : 1; // Tab: 15 grados, flechas: 1 grado
      
      // Si hay una transformación activa, usar las flechas/Tab para movimiento
      if (rectTransform.isTransforming || circleTransform.isTransforming) {
        const transform = rectTransform.isTransforming ? rectTransform : circleTransform;
        const activeHandle = transform.activeHandle;
        
        if (activeHandle === 'move') {
          // Mover con flechas/Tab durante movimiento
          if (e.key === 'ArrowLeft' || (isTab && e.shiftKey)) {
            e.preventDefault();
            if (rectTransform.isTransforming) {
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', 'move', { dx: -step, dy: 0 }, rectTransform.constraints);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (circleTransform.isTransforming) {
              const internalShape = positionSizeToCircle(circleShape.x, circleShape.y, circleShape.width, circleShape.height);
              const newShape = applyTransform(internalShape, 'circle', 'move', { dx: -step, dy: 0 }, circleTransform.constraints);
              const output = circleToPositionSize(newShape);
              setCircleShape(output);
            }
          } else if (e.key === 'ArrowRight' || (isTab && !e.shiftKey)) {
            e.preventDefault();
            if (rectTransform.isTransforming) {
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', 'move', { dx: step, dy: 0 }, rectTransform.constraints);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (circleTransform.isTransforming) {
              const internalShape = positionSizeToCircle(circleShape.x, circleShape.y, circleShape.width, circleShape.height);
              const newShape = applyTransform(internalShape, 'circle', 'move', { dx: step, dy: 0 }, circleTransform.constraints);
              const output = circleToPositionSize(newShape);
              setCircleShape(output);
            }
          } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (rectTransform.isTransforming) {
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', 'move', { dx: 0, dy: -step }, rectTransform.constraints);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (circleTransform.isTransforming) {
              const internalShape = positionSizeToCircle(circleShape.x, circleShape.y, circleShape.width, circleShape.height);
              const newShape = applyTransform(internalShape, 'circle', 'move', { dx: 0, dy: -step }, circleTransform.constraints);
              const output = circleToPositionSize(newShape);
              setCircleShape(output);
            }
          } else if (e.key === 'ArrowDown' || (isTab && !e.shiftKey && e.altKey)) {
            e.preventDefault();
            if (rectTransform.isTransforming) {
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', 'move', { dx: 0, dy: step }, rectTransform.constraints);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (circleTransform.isTransforming) {
              const internalShape = positionSizeToCircle(circleShape.x, circleShape.y, circleShape.width, circleShape.height);
              const newShape = applyTransform(internalShape, 'circle', 'move', { dx: 0, dy: step }, circleTransform.constraints);
              const output = circleToPositionSize(newShape);
              setCircleShape(output);
            }
          }
        } else if (activeHandle && activeHandle !== 'move' && activeHandle !== 'rotate' && activeHandle !== 'radius') {
          // Resize con flechas/Tab durante redimensionamiento
          if (rectTransform.isTransforming && activeHandle) {
            if (e.key === 'ArrowLeft' || (isTab && e.shiftKey)) {
              e.preventDefault();
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', activeHandle, { dx: -step, dy: 0 }, rectTransform.constraints, internalShape);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (e.key === 'ArrowRight' || (isTab && !e.shiftKey)) {
              e.preventDefault();
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', activeHandle, { dx: step, dy: 0 }, rectTransform.constraints, internalShape);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (e.key === 'ArrowUp') {
              e.preventDefault();
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', activeHandle, { dx: 0, dy: -step }, rectTransform.constraints, internalShape);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            } else if (e.key === 'ArrowDown') {
              e.preventDefault();
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', activeHandle, { dx: 0, dy: step }, rectTransform.constraints, internalShape);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            }
          }
        }
        return;
      }
      
      // Si no hay transformación activa, usar el icono visible para determinar la acción
      if (selectedShape === 'rect') {
        if (rectIsResizing && rectResizeHandle) {
          // Si está en modo resize (hover en bordes/esquinas), redimensionar
          if (e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'Tab') {
            e.preventDefault();
            let dx = 0;
            let dy = 0;
            if (e.key === 'ArrowLeft' || (e.key === 'Tab' && e.shiftKey)) {
              dx = -step;
            } else if (e.key === 'ArrowRight' || (e.key === 'Tab' && !e.shiftKey)) {
              dx = step;
            } else if (e.key === 'ArrowUp') {
              dy = -step;
            } else if (e.key === 'ArrowDown') {
              dy = step;
            }
            const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
            const newShape = applyTransform(internalShape, 'rect', rectResizeHandle, { dx, dy }, rectTransform.constraints, internalShape);
            const output = rectToPositionSize(newShape);
            setRectShape({ ...output, rotation: newShape.rotation });
          }
        } else if (rectCenterAction) {
          if (rectCenterAction === 'rotate') {
            // Solo rotar cuando el icono de girar está visible
            if (e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'Tab') {
              e.preventDefault();
              let rotationDelta = 0;
              if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
                rotationDelta = -rotationStep;
              } else if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
                rotationDelta = rotationStep;
              } else if (e.key === 'Tab') {
                // Tab: rotar 15 grados (positivo o negativo según shift)
                rotationDelta = e.shiftKey ? -rotationStep : rotationStep;
              }
              const currentRotation = rectShape.rotation || 0;
              let newRotation = currentRotation + rotationDelta;
              // Normalizar a rango 0-359
              // Manejar valores negativos y valores mayores a 359
              while (newRotation < 0) {
                newRotation += 360;
              }
              while (newRotation >= 360) {
                newRotation -= 360;
              }
              setRectShape({ ...rectShape, rotation: newRotation });
            }
          } else if (rectCenterAction === 'move') {
            // Solo mover cuando el icono de mover está visible
            if (e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'Tab') {
              e.preventDefault();
              let dx = 0;
              let dy = 0;
              if (e.key === 'ArrowLeft' || (e.key === 'Tab' && e.shiftKey)) {
                dx = -step;
              } else if (e.key === 'ArrowRight' || (e.key === 'Tab' && !e.shiftKey)) {
                dx = step;
              } else if (e.key === 'ArrowUp') {
                dy = -step;
              } else if (e.key === 'ArrowDown') {
                dy = step;
              }
              const internalShape = positionSizeToRect(rectShape.x, rectShape.y, rectShape.width, rectShape.height, rectShape.rotation || 0);
              const newShape = applyTransform(internalShape, 'rect', 'move', { dx, dy }, rectTransform.constraints);
              const output = rectToPositionSize(newShape);
              setRectShape({ ...output, rotation: newShape.rotation });
            }
          }
        }
      } else if (selectedShape === 'circle') {
        if (circleIsResizing) {
          // Si está en modo resize (hover en el borde), ampliar o achicar
          if (e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'Tab') {
            e.preventDefault();
            // Calcular el cambio de radio según la dirección
            // Para círculos, todas las flechas cambian el radio (ampliar/achicar)
            let radiusDelta = 0;
            if (e.key === 'ArrowLeft' || e.key === 'ArrowUp' || (e.key === 'Tab' && e.shiftKey)) {
              radiusDelta = -step; // Achicar
            } else if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || (e.key === 'Tab' && !e.shiftKey)) {
              radiusDelta = step; // Ampliar
            }
            
            const currentRadius = Math.min(circleShape.width, circleShape.height) / 2;
            const newRadius = Math.max(25, currentRadius + radiusDelta); // Mínimo 25px
            const newSize = newRadius * 2;
            
            setCircleShape({
              ...circleShape,
              width: newSize,
              height: newSize,
            });
          }
        } else {
          // Si no está en modo resize, mover (no giran)
          if (e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'Tab') {
            e.preventDefault();
            let dx = 0;
            let dy = 0;
            if (e.key === 'ArrowLeft' || (e.key === 'Tab' && e.shiftKey)) {
              dx = -step;
            } else if (e.key === 'ArrowRight' || (e.key === 'Tab' && !e.shiftKey)) {
              dx = step;
            } else if (e.key === 'ArrowUp') {
              dy = -step;
            } else if (e.key === 'ArrowDown') {
              dy = step;
            }
            const internalShape = positionSizeToCircle(circleShape.x, circleShape.y, circleShape.width, circleShape.height);
            const newShape = applyTransform(internalShape, 'circle', 'move', { dx, dy }, circleTransform.constraints);
            const output = circleToPositionSize(newShape);
            setCircleShape(output);
          }
        }
      }
    };
    
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [rectShape, circleShape, rectTransform.isTransforming, circleTransform.isTransforming, rectTransform.activeHandle, circleTransform.activeHandle, rectTransform.constraints, circleTransform.constraints, selectedShape, rectCenterAction, circleIsResizing, rectIsResizing, rectResizeHandle]);

  return (
    <div className="w-full h-screen bg-gradient-to-br from-gray-900 to-gray-800 flex items-center justify-center">
      {/* Badge de debug */}
      {activeDebug && (
        <div
          className="absolute top-4 left-4 z-50 bg-black/80 text-white text-xs font-mono p-3 rounded pointer-events-none select-none"
          style={{ zIndex: 9999, userSelect: 'none' }}
        >
          <div className="font-bold mb-1">Debug Transform</div>
          <div>Handle: <span className="text-orange-500">{activeDebug.handle || 'none'}</span></div>
          <div>x: {activeDebug.x.toFixed(1)}</div>
          <div>y: {activeDebug.y.toFixed(1)}</div>
          <div>w: {activeDebug.w.toFixed(1)}</div>
          <div>h: {activeDebug.h.toFixed(1)}</div>
          <div>rot: {activeDebug.rot.toFixed(1)}°</div>
          <div>scale: {activeDebug.scale.toFixed(2)}</div>
        </div>
      )}
      
      {/* Contenedor principal */}
      <div
        ref={containerRef}
        className="relative bg-gray-700 border-2 border-gray-600"
        style={{
          width: '800px',
          height: '600px',
        }}
        onClick={(e) => {
          // Deseleccionar si se hace clic en el contenedor (no en una forma)
          if (e.target === e.currentTarget) {
            setSelectedShape(null);
          }
        }}
      >
        {/* Imagen placeholder de fondo */}
        <div
          className="absolute inset-0 opacity-20 pointer-events-none"
          style={{
            backgroundImage: 'linear-gradient(45deg, #666 25%, transparent 25%), linear-gradient(-45deg, #666 25%, transparent 25%), linear-gradient(45deg, transparent 75%, #666 75%), linear-gradient(-45deg, transparent 75%, #666 75%)',
            backgroundSize: '40px 40px',
            backgroundPosition: '0 0, 0 20px, 20px -20px, -20px 0px',
          }}
        />
        
        {/* Rectángulo transformable */}
        <TransformableRect
          shape={rectShape}
          transform={rectTransform}
          onSelect={() => setSelectedShape('rect')}
          onCenterActionChange={(action) => setRectCenterAction(action)}
          onResizeModeChange={(isResizing, handle) => {
            setRectIsResizing(isResizing);
            setRectResizeHandle(handle);
          }}
        />
        
        {/* Círculo transformable */}
        <TransformableCircle
          shape={circleShape}
          transform={circleTransform}
          onSelect={() => setSelectedShape('circle')}
          onResizeModeChange={(isResizing) => setCircleIsResizing(isResizing)}
        />
      </div>
    </div>
  );
}

// Componente para rectángulo transformable
interface TransformableRectProps {
  shape: RectInput;
  transform: ReturnType<typeof useTransformGestures>;
  onSelect?: () => void;
  onCenterActionChange?: (action: 'move' | 'rotate' | null) => void;
  onResizeModeChange?: (isResizing: boolean, handle: TransformHandle | null) => void;
}

function TransformableRect({ shape, transform, onSelect, onCenterActionChange, onResizeModeChange }: TransformableRectProps) {
  const elementRef = useRef<HTMLDivElement>(null);
  const [hoverZone, setHoverZone] = useState<'corner-nw' | 'corner-ne' | 'corner-sw' | 'corner-se' | 'edge-n' | 'edge-s' | 'edge-w' | 'edge-e' | 'center-rotate' | 'center-move' | null>(null);
  const [rectIsResizing, setRectIsResizing] = useState(false);
  const lastMousePosRef = useRef<{ relX: number; relY: number } | null>(null);
  
  // Función para calcular hoverZone basado en posición relativa
  const calculateHoverZone = useCallback((relX: number, relY: number) => {
    // Guardar posición relativa
    lastMousePosRef.current = { relX, relY };
    
    const cornerRadius = Math.min(shape.width, shape.height) * 0.05; // 5% del lado más pequeño
    const edgeThreshold = 8; // Umbral para detectar bordes
    
    // Centro del rectángulo (donde está el eje cartesiano)
    const centerX = shape.width / 2;
    const centerY = shape.height / 2;
    const distanceFromCenter = Math.sqrt((relX - centerX) ** 2 + (relY - centerY) ** 2);
    
    // Radio del círculo que inscribe el eje cartesiano (ampliado para mayor área de rotación)
    const axisCircleRadius = 40; // Aumentado de 25px a 40px
    
    // Detectar esquinas (círculo imaginario del 5%)
    const distFromNW = Math.sqrt((relX - 0) ** 2 + (relY - 0) ** 2);
    const distFromNE = Math.sqrt((relX - shape.width) ** 2 + (relY - 0) ** 2);
    const distFromSW = Math.sqrt((relX - 0) ** 2 + (relY - shape.height) ** 2);
    const distFromSE = Math.sqrt((relX - shape.width) ** 2 + (relY - shape.height) ** 2);
    
    if (distFromNW < cornerRadius) {
      setHoverZone('corner-nw');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'nw');
      onCenterActionChange?.(null);
    } else if (distFromNE < cornerRadius) {
      setHoverZone('corner-ne');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'ne');
      onCenterActionChange?.(null);
    } else if (distFromSW < cornerRadius) {
      setHoverZone('corner-sw');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'sw');
      onCenterActionChange?.(null);
    } else if (distFromSE < cornerRadius) {
      setHoverZone('corner-se');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'se');
      onCenterActionChange?.(null);
    } else if (relY < edgeThreshold && relX > cornerRadius && relX < shape.width - cornerRadius) {
      setHoverZone('edge-n');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'n');
      onCenterActionChange?.(null);
    } else if (relY > shape.height - edgeThreshold && relX > cornerRadius && relX < shape.width - cornerRadius) {
      setHoverZone('edge-s');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 's');
      onCenterActionChange?.(null);
    } else if (relX < edgeThreshold && relY > cornerRadius && relY < shape.height - cornerRadius) {
      setHoverZone('edge-w');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'w');
      onCenterActionChange?.(null);
    } else if (relX > shape.width - edgeThreshold && relY > cornerRadius && relY < shape.height - cornerRadius) {
      setHoverZone('edge-e');
      setRectIsResizing(true);
      onResizeModeChange?.(true, 'e');
      onCenterActionChange?.(null);
    } else {
      // Dentro del área central: distinguir entre círculo del eje (rotar) y resto (mover)
      setRectIsResizing(false);
      onResizeModeChange?.(false, null);
      if (distanceFromCenter <= axisCircleRadius) {
        setHoverZone('center-rotate');
        onCenterActionChange?.('rotate');
      } else {
        setHoverZone('center-move');
        onCenterActionChange?.('move');
      }
    }
  }, [shape, onCenterActionChange, onResizeModeChange]);
  
  const handleMouseMove = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const relX = e.clientX - rect.left;
    const relY = e.clientY - rect.top;
    calculateHoverZone(relX, relY);
  };

  // Handler para pointer events (funciona con mouse y touch)
  const handlePointerMove = (e: React.PointerEvent) => {
    // Solo actualizar hoverZone si no se está transformando (para evitar conflictos)
    if (!transform.isTransforming) {
      const rect = e.currentTarget.getBoundingClientRect();
      const relX = e.clientX - rect.left;
      const relY = e.clientY - rect.top;
      calculateHoverZone(relX, relY);
    }
  };
  
  // Recalcular hoverZone cuando el objeto cambia de posición o tamaño
  useEffect(() => {
    if (lastMousePosRef.current && elementRef.current) {
      const { relX, relY } = lastMousePosRef.current;
      // Recalcular basado en la posición relativa guardada
      calculateHoverZone(relX, relY);
    }
  }, [shape.x, shape.y, shape.width, shape.height, shape.rotation, calculateHoverZone]);
  
  const getCursor = () => {
    if (transform.isTransforming) {
      return transform.activeHandle === 'rotate' ? 'grabbing' : 'grabbing';
    }
    
    switch (hoverZone) {
      case 'corner-nw':
      case 'corner-se':
        return 'nwse-resize';
      case 'corner-ne':
      case 'corner-sw':
        return 'nesw-resize';
      case 'edge-n':
      case 'edge-s':
        return 'ns-resize';
      case 'edge-w':
      case 'edge-e':
        return 'ew-resize';
      case 'center-rotate':
        return 'grab';
      case 'center-move':
        return 'move';
      default:
        return 'default';
    }
  };
  
  const handlePointerDown = (e: React.PointerEvent) => {
    // Si está en el círculo del eje cartesiano, rotar
    if (hoverZone === 'center-rotate') {
      e.stopPropagation();
      transform.startTransform(e, 'rotate', elementRef.current || undefined);
      return;
    }
    
    // Si está en el centro pero fuera del círculo del eje, mover
    if (hoverZone === 'center-move') {
      transform.startTransform(e, 'move', elementRef.current || undefined);
      return;
    }
    
    // Mapear zona a handle
    let handle: TransformHandle | null = null;
    switch (hoverZone) {
      case 'corner-nw':
        handle = 'nw';
        break;
      case 'corner-ne':
        handle = 'ne';
        break;
      case 'corner-sw':
        handle = 'sw';
        break;
      case 'corner-se':
        handle = 'se';
        break;
      case 'edge-n':
        handle = 'n';
        break;
      case 'edge-s':
        handle = 's';
        break;
      case 'edge-w':
        handle = 'w';
        break;
      case 'edge-e':
        handle = 'e';
        break;
    }
    
    if (handle) {
      e.stopPropagation();
      console.debug('[TransformPlayground] Resize start:', { handle, hoverZone, shape });
      transform.startTransform(e, handle, elementRef.current || undefined);
    }
  };
  
  // Calcular posición absoluta del centro para los ejes fijos
  const centerX = shape.x + shape.width / 2;
  const centerY = shape.y + shape.height / 2;
  
  // Normalizar ángulo a rango 0-360 (siempre, sin importar cuántas vueltas)
  // Usar módulo para mantener valores en 0-360, pero mostrar 360° cuando corresponde
  let displayRotation = shape.rotation || 0;
  // Normalizar a rango 0-360 (no 0-359) para mostrar 360° correctamente
  displayRotation = ((displayRotation % 360) + 360) % 360;
  // Si el valor es muy cercano a 360, mostrarlo como 360 (no 0)
  if (displayRotation > 359.5) {
    displayRotation = 360;
  } else if (displayRotation < 0.5) {
    displayRotation = 0;
  }
  
  return (
    <>
      {/* Eje cartesiano fijo (naranja) - fuera del contenedor rotado, posicionado absolutamente */}
      <div 
        className="absolute z-10 pointer-events-none"
        style={{
          left: `${centerX - 25}px`,
          top: `${centerY - 25}px`,
          width: '50px',
          height: '50px'
        }}
      >
        <svg 
          width="50"
          height="50"
          viewBox="0 0 50 50"
          className="pointer-events-none"
        >
          {/* Eje horizontal (X) fijo naranja */}
          <line
            x1="0"
            y1="25"
            x2="50"
            y2="25"
            stroke="#f97316"
            strokeWidth="1"
            strokeDasharray="2 2"
            opacity="0.7"
          />
          {/* Eje vertical (Y) fijo naranja */}
          <line
            x1="25"
            y1="0"
            x2="25"
            y2="50"
            stroke="#f97316"
            strokeWidth="1"
            strokeDasharray="2 2"
            opacity="0.7"
          />
        </svg>
        
        {/* Texto de grados fijo arriba del eje naranja - mostrar siempre que haya rotación o se esté transformando */}
        {(displayRotation > 0.5 || (transform.isTransforming && transform.activeHandle === 'rotate')) && (
          <div
            className="absolute pointer-events-none select-none"
            style={{
              left: '25px',
              top: '-15px',
              transform: 'translate(-50%, -100%)',
              transformOrigin: '50% 100%',
              color: '#f97316',
              fontSize: '14px',
              fontWeight: 'bold',
              fontFamily: 'system-ui, -apple-system, sans-serif',
              textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
              whiteSpace: 'nowrap',
              zIndex: 2
            }}
          >
            {Math.round(displayRotation)}°
          </div>
        )}
      </div>
      
      {/* Contenedor del rectángulo rotado */}
      <div
        ref={elementRef}
        className="absolute pointer-events-auto touch-action-none"
        style={{
          left: `${shape.x}px`,
          top: `${shape.y}px`,
          width: `${shape.width}px`,
          height: `${shape.height}px`,
          transform: `rotate(${shape.rotation}deg)`,
          transformOrigin: 'center',
          cursor: getCursor(),
        }}
        onMouseMove={handleMouseMove}
        onPointerMove={handlePointerMove}
        onMouseLeave={() => {
          if (!transform.isTransforming) {
            setHoverZone(null);
            setRectIsResizing(false);
            onCenterActionChange?.(null);
            onResizeModeChange?.(false, null);
          }
        }}
        onPointerDown={(e) => {
          onSelect?.();
          handlePointerDown(e);
        }}
        onClick={(e) => {
          e.stopPropagation();
          onSelect?.();
        }}
      >
        {/* Outline del rectángulo */}
        <div
          className="w-full h-full border-2 border-orange-500 bg-orange-500/10 pointer-events-none"
        />
      
        
        {/* Ángulo de giro (naranja) - solo cuando se está girando */}
        {transform.isTransforming && transform.activeHandle === 'rotate' && (() => {
          // Normalizar rotación para el cálculo del arco (0-360)
          const normalizedRotation = ((shape.rotation || 0) % 360 + 360) % 360;
          const rotationRad = (normalizedRotation * Math.PI) / 180;
          return (
            <svg 
              width="50"
              height="50"
              viewBox="0 0 50 50"
              className="pointer-events-none"
              style={{ 
                position: 'absolute',
                left: '0',
                top: '0'
              }}
            >
              {/* Arco del ángulo entre los ejes */}
              <path
                d={`M 25 5 A 20 20 0 ${normalizedRotation > 180 ? 1 : 0} ${normalizedRotation > 0 ? 1 : 0} ${25 + 20 * Math.sin(rotationRad)} ${25 - 20 * Math.cos(rotationRad)} L 25 25 Z`}
                fill="rgba(249, 115, 22, 0.2)"
                stroke="#f97316"
                strokeWidth="1"
              />
              {/* Línea desde el centro hasta el punto final del arco */}
              <line
                x1="25"
                y1="25"
                x2={25 + 20 * Math.sin(rotationRad)}
                y2={25 - 20 * Math.cos(rotationRad)}
                stroke="#f97316"
                strokeWidth="1"
                strokeDasharray="2 2"
              />
            </svg>
          );
        })()}
        
        {/* Icono de rotar centrado - solo visible cuando se está sobre el círculo del eje */}
        {hoverZone === 'center-rotate' && (
          <div
            className="absolute pointer-events-none"
            style={{ 
              left: '50%',
              top: '50%',
              transform: 'translate(-50%, -50%)',
              width: '20px',
              height: '20px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              zIndex: 1
            }}
          >
            <RotateCw className="w-5 h-5 text-white" />
          </div>
        )}
        
        {/* Icono de mover - visible cuando se está en el centro pero fuera del círculo del eje */}
        {hoverZone === 'center-move' && !rectIsResizing && (
          <div
            className="absolute pointer-events-none"
            style={{ 
              left: '50%',
              top: '50%',
              transform: 'translate(-50%, -50%)',
              width: '20px',
              height: '20px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              zIndex: 1
            }}
          >
            <Move className="w-5 h-5 text-white" />
          </div>
        )}
        
        {/* Iconos de ampliar/achicar - visible cuando estamos en modo resize */}
        {(hoverZone === 'corner-nw' || hoverZone === 'corner-ne' || hoverZone === 'corner-sw' || hoverZone === 'corner-se' || 
          hoverZone === 'edge-n' || hoverZone === 'edge-s' || hoverZone === 'edge-w' || hoverZone === 'edge-e') && (
          <div
            className="absolute pointer-events-none"
            style={{ 
              left: '50%',
              top: '50%',
              transform: 'translate(-50%, -50%)',
              width: '24px',
              height: '24px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              zIndex: 1
            }}
          >
            <div className="flex flex-col items-center gap-0.5">
              <Maximize2 className="w-3 h-3 text-white" />
              <Minimize2 className="w-3 h-3 text-white" />
            </div>
          </div>
        )}
      </div>
    </>
  );
}

// Componente para círculo transformable
interface TransformableCircleProps {
  shape: CircleInput;
  transform: ReturnType<typeof useTransformGestures>;
  onSelect?: () => void;
  onResizeModeChange?: (isResizing: boolean) => void;
}

function TransformableCircle({ shape, transform, onSelect, onResizeModeChange }: TransformableCircleProps) {
  const elementRef = useRef<HTMLDivElement>(null);
  const [isHoveringEdge, setIsHoveringEdge] = useState(false);
  const [edgeAngle, setEdgeAngle] = useState<number | null>(null);
  const lastMousePosRef = useRef<{ relX: number; relY: number } | null>(null);
  const radius = Math.min(shape.width, shape.height) / 2;
  
  // Función para calcular hover basado en posición relativa
  const calculateHover = useCallback((relX: number, relY: number) => {
    // Guardar posición relativa
    lastMousePosRef.current = { relX, relY };
    
    const centerX = shape.width / 2;
    const centerY = shape.height / 2;
    const distanceFromCenter = Math.sqrt(
      (relX - centerX) ** 2 + (relY - centerY) ** 2
    );
    const currentRadius = Math.min(shape.width, shape.height) / 2;
    const edgeThreshold = 12;
    const hovering = Math.abs(distanceFromCenter - currentRadius) < edgeThreshold;
    setIsHoveringEdge(hovering);
    onResizeModeChange?.(hovering);
    
    if (hovering) {
      // Calcular ángulo desde el centro hasta el mouse (en grados)
      const angle = Math.atan2(relY - centerY, relX - centerX) * (180 / Math.PI);
      setEdgeAngle(angle);
    } else {
      setEdgeAngle(null);
    }
  }, [shape.width, shape.height, onResizeModeChange]);
  
  const handleMouseMove = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const relX = e.clientX - rect.left;
    const relY = e.clientY - rect.top;
    calculateHover(relX, relY);
  };
  
  // Recalcular hover cuando el objeto cambia de posición o tamaño
  useEffect(() => {
    if (lastMousePosRef.current && elementRef.current) {
      const { relX, relY } = lastMousePosRef.current;
      // Recalcular basado en la posición relativa guardada
      calculateHover(relX, relY);
    }
  }, [shape.x, shape.y, shape.width, shape.height, calculateHover]);
  
  const handlePointerDown = (e: React.PointerEvent) => {
    if (isHoveringEdge) {
      // Si está cerca del borde, iniciar resize
      e.stopPropagation();
      transform.startTransform(e, 'radius', elementRef.current || undefined);
    } else {
      // Si no, iniciar movimiento (solo mover, no rotar)
      e.stopPropagation();
      transform.startTransform(e, 'move', elementRef.current || undefined);
    }
  };
  
  return (
    <div
      ref={elementRef}
      className="absolute pointer-events-auto touch-action-none"
      style={{
        left: `${shape.x}px`,
        top: `${shape.y}px`,
        width: `${shape.width}px`,
        height: `${shape.height}px`,
        cursor: transform.isTransforming 
          ? (transform.activeHandle === 'radius' ? 'grabbing' : 'grabbing')
          : isHoveringEdge && edgeAngle !== null
          ? (() => {
              // Normalizar ángulo a 0-360
              let angle = ((edgeAngle % 360) + 360) % 360;
              // Determinar cursor según dirección radial (perpendicular al contorno)
              // El cursor debe apuntar hacia afuera desde el centro
              if (angle >= 337.5 || angle < 22.5) return 'ew-resize'; // Derecha
              if (angle >= 22.5 && angle < 67.5) return 'nwse-resize'; // Diagonal NE-SW
              if (angle >= 67.5 && angle < 112.5) return 'ns-resize'; // Arriba
              if (angle >= 112.5 && angle < 157.5) return 'nesw-resize'; // Diagonal NW-SE
              if (angle >= 157.5 && angle < 202.5) return 'ew-resize'; // Izquierda
              if (angle >= 202.5 && angle < 247.5) return 'nwse-resize'; // Diagonal SW-NE
              if (angle >= 247.5 && angle < 292.5) return 'ns-resize'; // Abajo
              if (angle >= 292.5 && angle < 337.5) return 'nesw-resize'; // Diagonal SE-NW
              return 'nwse-resize'; // default
            })()
          : 'move',
      }}
      onMouseMove={handleMouseMove}
      onMouseLeave={() => {
        setIsHoveringEdge(false);
        onResizeModeChange?.(false);
      }}
      onPointerDown={(e) => {
        onSelect?.();
        handlePointerDown(e);
      }}
      onClick={(e) => {
        e.stopPropagation();
        onSelect?.();
      }}
    >
      {/* Outline del círculo */}
      <div
        className="w-full h-full border-2 border-blue-500 bg-blue-500/10 rounded-full pointer-events-none"
      />
      
      {/* Icono de mover en el centro - solo cuando no estamos en modo resize */}
      {!isHoveringEdge && (
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
            <Move className="w-5 h-5 text-white hover:text-blue-500 transition-colors" />
          </div>
        </div>
      )}
      
      {/* Iconos de ampliar/achicar - visible cuando estamos en modo resize (hover en el borde) */}
      {isHoveringEdge && (
        <div
          className="absolute pointer-events-none"
          style={{ 
            left: '50%',
            top: '50%',
            transform: 'translate(-50%, -50%)',
            width: '24px',
            height: '24px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1
          }}
        >
          <div className="flex flex-col items-center gap-0.5">
            <Maximize2 className="w-3 h-3 text-white" />
            <Minimize2 className="w-3 h-3 text-white" />
          </div>
        </div>
      )}
    </div>
  );
}

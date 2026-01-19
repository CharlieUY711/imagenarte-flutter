/**
 * Playground para probar transformaciones (move/rotate)
 * 
 * Acceso: localhost:5178/transform-playground (o toggle en UI)
 * 
 * Este componente ahora usa el módulo Transform profesional
 */

import { useState, useRef, useEffect } from 'react';
import {
  useTransformController,
  TransformOverlay,
} from '../../modules/transform/adapters/react';
import type { Shape } from '../../modules/transform/core/types';
import { rectToQuad, quadToRect, circleToShape, shapeToCircle } from './transformHelpers';

export function TransformPlayground() {
  const containerRef = useRef<HTMLDivElement>(null);
  const [shapeType, setShapeType] = useState<'quad' | 'circle'>('quad');
  const [showDebug, setShowDebug] = useState(false);

  // Estado inicial según el tipo de forma
  const getInitialShape = (): Shape => {
    if (shapeType === 'quad') {
      return rectToQuad(150, 150, 200, 150, 0);
    } else {
      return circleToShape(400, 200, 150, 150);
    }
  };

  const [currentShape, setCurrentShape] = useState<Shape>(getInitialShape());

  // Hook del módulo Transform
  const transform = useTransformController({
    initialShape: currentShape,
    config: {
      quadInnerInsetRatio: 0.10, // 10% hacia el centro para zona de rotación
    },
    containerRef,
  });

  // Sincronizar cambios del módulo con el estado local
  useEffect(() => {
    setCurrentShape(transform.state.shape);
  }, [transform.state.shape]);

  // Reset de la forma
  const handleReset = () => {
    const newShape = getInitialShape();
    transform.setShape(newShape);
    setCurrentShape(newShape);
  };

  // Toggle entre QUAD y CIRCLE
  const handleToggleShape = () => {
    const newType = shapeType === 'quad' ? 'circle' : 'quad';
    setShapeType(newType);
    const newShape = newType === 'quad' 
      ? rectToQuad(150, 150, 200, 150, 0)
      : circleToShape(400, 200, 150, 150);
    transform.setShape(newShape);
    setCurrentShape(newShape);
  };

  // Obtener información de debug
  const getDebugInfo = () => {
    if (transform.state.isDragging) {
      if (transform.state.shape.kind === 'quad') {
        const rect = quadToRect(transform.state.shape);
        return {
          mode: transform.state.dragMode,
          x: rect.x.toFixed(1),
          y: rect.y.toFixed(1),
          w: rect.width.toFixed(1),
          h: rect.height.toFixed(1),
          rot: rect.rotation.toFixed(1),
        };
      } else {
        const circle = shapeToCircle(transform.state.shape);
        return {
          mode: transform.state.dragMode,
          x: circle.x.toFixed(1),
          y: circle.y.toFixed(1),
          w: circle.width.toFixed(1),
          h: circle.height.toFixed(1),
          rot: '0.0',
        };
      }
    }
    return null;
  };

  const debugInfo = getDebugInfo();

  return (
    <div className="w-full h-screen bg-gradient-to-br from-gray-900 to-gray-800 flex items-center justify-center">
      {/* Badge de debug */}
      {debugInfo && (
        <div
          className="absolute top-4 left-4 z-50 bg-black/80 text-white text-xs font-mono p-3 rounded pointer-events-none select-none"
          style={{ zIndex: 9999, userSelect: 'none' }}
        >
          <div className="font-bold mb-1">Debug Transform</div>
          <div>Mode: <span className="text-orange-500">{debugInfo.mode}</span></div>
          <div>x: {debugInfo.x}</div>
          <div>y: {debugInfo.y}</div>
          <div>w: {debugInfo.w}</div>
          <div>h: {debugInfo.h}</div>
          <div>rot: {debugInfo.rot}°</div>
        </div>
      )}

      {/* Controles */}
      <div className="absolute top-4 right-4 z-50 flex gap-2">
        <button
          onClick={handleToggleShape}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded"
        >
          Toggle: {shapeType === 'quad' ? 'QUAD' : 'CIRCLE'}
        </button>
        <button
          onClick={handleReset}
          className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded"
        >
          Reset
        </button>
        <label className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded cursor-pointer flex items-center gap-2">
          <input
            type="checkbox"
            checked={showDebug}
            onChange={(e) => setShowDebug(e.target.checked)}
            className="cursor-pointer"
          />
          Debug
        </label>
      </div>

      {/* Contenedor principal */}
      <div
        ref={containerRef}
        className="relative bg-gray-700 border-2 border-gray-600"
        style={{
          width: '800px',
          height: '600px',
        }}
        onPointerMove={transform.handlers.onPointerMove}
        onPointerDown={transform.handlers.onPointerDown}
        onPointerUp={transform.handlers.onPointerUp}
        onPointerCancel={transform.handlers.onPointerCancel}
      >
        {/* Imagen placeholder de fondo */}
        <div
          className="absolute inset-0 opacity-20 pointer-events-none"
          style={{
            backgroundImage:
              'linear-gradient(45deg, #666 25%, transparent 25%), linear-gradient(-45deg, #666 25%, transparent 25%), linear-gradient(45deg, transparent 75%, #666 75%), linear-gradient(-45deg, transparent 75%, #666 75%)',
            backgroundSize: '40px 40px',
            backgroundPosition: '0 0, 0 20px, 20px -20px, -20px 0px',
          }}
        />

        {/* Overlay de transformación */}
        <TransformOverlay
          shape={transform.state.shape}
          showIcon={transform.ui.showIcon}
          iconMode={transform.ui.iconMode}
          iconCenter={transform.ui.center}
          showDebug={showDebug}
        />
      </div>
    </div>
  );
}

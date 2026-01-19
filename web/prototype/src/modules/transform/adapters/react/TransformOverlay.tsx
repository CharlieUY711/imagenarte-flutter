/**
 * Overlay que renderiza la forma (quad/circle) y el icono central
 * 
 * Todo con pointer-events: none para no bloquear interacciones
 */

import type { Shape } from '../../core/types';
import { TransformCenterIcon } from './TransformCenterIcon';
import { quadCenter } from '../../core/geometry';

export interface TransformOverlayProps {
  shape: Shape;
  showIcon: boolean;
  iconMode: 'MOVE' | 'ROTATE';
  iconCenter: { x: number; y: number };
  showDebug?: boolean;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Renderiza un cuadrilátero
 */
function QuadOverlay({
  points,
  showDebug,
}: {
  points: [typeof points[0], typeof points[1], typeof points[2], typeof points[3]];
  showDebug?: boolean;
}) {
  // Calcular bounding box
  const xs = points.map((p) => p.x);
  const ys = points.map((p) => p.y);
  const minX = Math.min(...xs);
  const minY = Math.min(...ys);
  const maxX = Math.max(...xs);
  const maxY = Math.max(...ys);
  const width = maxX - minX;
  const height = maxY - minY;

  // Ajustar puntos relativos al bounding box
  const relativePoints = points.map((p) => ({
    x: p.x - minX,
    y: p.y - minY,
  }));

  // Convertir puntos a string de path SVG
  const pathData = `M ${relativePoints[0].x} ${relativePoints[0].y} L ${relativePoints[1].x} ${relativePoints[1].y} L ${relativePoints[2].x} ${relativePoints[2].y} L ${relativePoints[3].x} ${relativePoints[3].y} Z`;

  const center = quadCenter(points);

  return (
    <>
      {/* Outline del quad */}
      <svg
        className="absolute inset-0 pointer-events-none"
        style={{ width: '100%', height: '100%', overflow: 'visible' }}
      >
        <path
          d={pathData}
          fill="rgba(249, 115, 22, 0.1)"
          stroke="#f97316"
          strokeWidth="2"
        />
      </svg>

      {/* Debug: inner quad (zona de rotación) */}
      {showDebug && (
        <svg
          className="absolute inset-0 pointer-events-none"
          style={{ width: '100%', height: '100%', overflow: 'visible' }}
        >
          {/* Calcular inner quad (10% hacia el centro) */}
          {(() => {
            const innerPoints = points.map((p) => ({
              x: p.x + (center.x - p.x) * 0.1 - minX,
              y: p.y + (center.y - p.y) * 0.1 - minY,
            }));
            const innerPath = `M ${innerPoints[0].x} ${innerPoints[0].y} L ${innerPoints[1].x} ${innerPoints[1].y} L ${innerPoints[2].x} ${innerPoints[2].y} L ${innerPoints[3].x} ${innerPoints[3].y} Z`;
            return (
              <path
                d={innerPath}
                fill="rgba(249, 115, 22, 0.05)"
                stroke="#f97316"
                strokeWidth="1"
                strokeDasharray="2 2"
              />
            );
          })()}
        </svg>
      )}
    </>
  );
}

/**
 * Renderiza un círculo
 */
function CircleOverlay({
  center,
  radius,
  offsetX,
  offsetY,
}: {
  center: { x: number; y: number };
  radius: number;
  offsetX: number;
  offsetY: number;
}) {
  // Calcular posición relativa al offset
  const relativeCenterX = center.x - offsetX;
  const relativeCenterY = center.y - offsetY;

  return (
    <div
      className="absolute pointer-events-none border-2 border-orange-500 bg-orange-500/10 rounded-full"
      style={{
        left: `${relativeCenterX - radius}px`,
        top: `${relativeCenterY - radius}px`,
        width: `${radius * 2}px`,
        height: `${radius * 2}px`,
      }}
    />
  );
}

/**
 * Componente principal del overlay
 */
export function TransformOverlay({
  shape,
  showIcon,
  iconMode,
  iconCenter,
  showDebug = false,
  className = '',
  style,
}: TransformOverlayProps) {
  // Calcular bounding box para posicionar el overlay
  let minX = 0;
  let minY = 0;
  let maxX = 0;
  let maxY = 0;

  if (shape.kind === 'quad') {
    const xs = shape.points.map((p) => p.x);
    const ys = shape.points.map((p) => p.y);
    minX = Math.min(...xs);
    minY = Math.min(...ys);
    maxX = Math.max(...xs);
    maxY = Math.max(...ys);
  } else {
    minX = shape.center.x - shape.radius;
    minY = shape.center.y - shape.radius;
    maxX = shape.center.x + shape.radius;
    maxY = shape.center.y + shape.radius;
  }

  const width = maxX - minX;
  const height = maxY - minY;

  return (
    <>
      {/* Overlay de la forma */}
      <div
        className={`absolute pointer-events-none ${className}`}
        style={{
          left: `${minX}px`,
          top: `${minY}px`,
          width: `${width}px`,
          height: `${height}px`,
          ...style,
        }}
      >
        {shape.kind === 'quad' ? (
          <QuadOverlay
            points={shape.points}
            showDebug={showDebug}
            offsetX={minX}
            offsetY={minY}
          />
        ) : (
          <CircleOverlay
            center={shape.center}
            radius={shape.radius}
            offsetX={minX}
            offsetY={minY}
          />
        )}
      </div>

      {/* Icono central (posicionado absolutamente en el contenedor) */}
      {showIcon && (
        <TransformCenterIcon
          mode={iconMode}
          x={iconCenter.x}
          y={iconCenter.y}
        />
      )}
    </>
  );
}

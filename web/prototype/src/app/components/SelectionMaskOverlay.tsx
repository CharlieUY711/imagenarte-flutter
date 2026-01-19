/**
 * Componente de máscara visual para la selección
 * - Dentro de la figura: imagen normal (máxima luminosidad)
 * - Fuera: overlay semitransparente oscuro
 * 
 * Usa SVG mask para crear el efecto de "agujero" en el overlay oscuro
 */

import type { Shape } from '@/modules/transform/core/types';

interface SelectionMaskOverlayProps {
  shape: Shape;
  containerWidth: number;
  containerHeight: number;
  opacity?: number;
}

export function SelectionMaskOverlay({
  shape,
  containerWidth,
  containerHeight,
  opacity = 0.55,
}: SelectionMaskOverlayProps) {
  // Generar ID único para el mask (evitar conflictos)
  const maskId = `selection-mask-${Math.random().toString(36).substr(2, 9)}`;

  return (
    <div
      className="absolute inset-0 pointer-events-none"
      style={{
        width: `${containerWidth}px`,
        height: `${containerHeight}px`,
        zIndex: 5, // Por encima de la imagen pero debajo del transform overlay
      }}
    >
      <svg
        className="absolute inset-0"
        style={{ width: '100%', height: '100%' }}
      >
        <defs>
          <mask id={maskId}>
            {/* Fondo blanco (opaco) = área visible del overlay */}
            <rect width="100%" height="100%" fill="white" />
            {/* Área negra (transparente) = "agujero" donde se ve la imagen normal */}
            {shape.kind === 'circle' ? (
              <circle
                cx={shape.center.x}
                cy={shape.center.y}
                r={shape.radius}
                fill="black"
              />
            ) : (
              <polygon
                points={shape.points.map(p => `${p.x},${p.y}`).join(' ')}
                fill="black"
              />
            )}
          </mask>
        </defs>
        {/* Overlay oscuro con máscara aplicada */}
        <rect
          width="100%"
          height="100%"
          fill={`rgba(0, 0, 0, ${opacity})`}
          mask={`url(#${maskId})`}
        />
      </svg>
    </div>
  );
}

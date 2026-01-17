/**
 * Icono central que muestra MOVE o ROTATE según el modo
 * 
 * pointer-events: none para no bloquear interacciones
 */

import { Move, RotateCw } from 'lucide-react';

export interface TransformCenterIconProps {
  mode: 'MOVE' | 'ROTATE';
  x: number;
  y: number;
  size?: number;
}

export function TransformCenterIcon({
  mode,
  x,
  y,
  size = 20,
}: TransformCenterIconProps) {
  const Icon = mode === 'ROTATE' ? RotateCw : Move;

  return (
    <div
      className="absolute pointer-events-none"
      style={{
        left: `${x}px`,
        top: `${y}px`,
        transform: 'translate(-50%, -50%)',
        width: `${size}px`,
        height: `${size}px`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1,
      }}
    >
      <Icon className="w-5 h-5 text-white" />
    </div>
  );
}

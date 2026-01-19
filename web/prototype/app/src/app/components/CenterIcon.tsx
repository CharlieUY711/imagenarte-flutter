/**
 * ICONO CENTRAL ÚNICO
 * 
 * Muestra un solo icono en el centro según el modo activo:
 * - MOVE: cuatro flechas (↔︎ ↕︎)
 * - RESIZE: flechas diagonales (↗︎ ↙︎)
 */

import React from 'react';

export type IconMode = 'move' | 'resize';

export interface CenterIconProps {
  mode: IconMode;
  x: number;
  y: number;
  size?: number;
}

export function CenterIcon({ mode, x, y, size = 24 }: CenterIconProps) {
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
        zIndex: 1000,
      }}
    >
      {mode === 'move' ? (
        // MOVE: 4 flechas (↔︎↕︎)
        <svg
          width={size}
          height={size}
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="text-white drop-shadow-lg"
        >
          <path
            d="M12 2L12 8M12 16L12 22M2 12L8 12M16 12L22 12"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <circle cx="12" cy="12" r="2" fill="currentColor" />
        </svg>
      ) : (
        // RESIZE: flechas diagonales (↗︎↙︎)
        <svg
          width={size}
          height={size}
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="text-white drop-shadow-lg"
        >
          <path
            d="M7 17L17 7M17 7H11M17 7V13"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <path
            d="M17 17L7 7M7 7H13M7 7V13"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      )}
    </div>
  );
}

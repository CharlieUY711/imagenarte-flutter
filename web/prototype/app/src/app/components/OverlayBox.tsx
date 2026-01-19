import { ReactNode } from 'react';

interface OverlayBoxProps {
  children: ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Contenedor estándar obligatorio para todos los overlays del editor.
 * 
 * Características:
 * - Altura fija: 60px
 * - Ancho: exactamente igual al DialButton (w-full del contenedor padre)
 * - Estilo visual:
 *   - Fondo: negro/gris oscuro transparente (rgba(0,0,0,0.55))
 *   - Borde: del mismo color que el relleno (border-black/55)
 *   - Sombra suave (blur)
 *   - Border radius: rounded-sm (igual al DialButton)
 *   - Padding horizontal: px-3 (consistente con DialButton)
 * - Contenido centrado verticalmente
 * - El contenedor puede posicionarse donde se necesite
 * - El contenido interno NO define posición ni fondo
 */
export function OverlayBox({ 
  children, 
  className = '',
  style 
}: OverlayBoxProps) {
  return (
    <div
      className={`
        relative w-full px-3 rounded-sm
        h-[60px] flex items-center
        bg-black/55 backdrop-blur-sm
        border border-black/55
        shadow-lg
        pointer-events-none
        ${className}
      `}
      style={style}
    >
      {/* Contenido interno puede tener pointer-events: auto si es interactivo */}
      <div className="pointer-events-auto w-full">
        {children}
      </div>
    </div>
  );
}

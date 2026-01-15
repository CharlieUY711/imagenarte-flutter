/**
 * Motivo de identidad visual - Imagen@rte
 * Basado en lógica radial incompleta con eje diagonal a 14:45
 * Uso: backgrounds sutiles, estados de carga, stepper
 */

interface RadialMotifProps {
  variant: 'background' | 'loading' | 'progress';
  progress?: number; // 0-100 para variant 'progress'
  className?: string;
}

export function RadialMotif({ variant, progress = 0, className = '' }: RadialMotifProps) {
  if (variant === 'background') {
    // Background sutil para Home/Export
    // Arco parcial diagonal muy tenue
    return (
      <svg
        className={`absolute inset-0 w-full h-full pointer-events-none ${className}`}
        viewBox="0 0 390 844"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
      >
        {/* Arco parcial superior derecha */}
        <path
          d="M 390 0 A 600 600 0 0 0 0 600"
          stroke="currentColor"
          strokeWidth="1"
          fill="none"
          opacity="0.03"
        />
        
        {/* Arco parcial inferior izquierda (reflejo diagonal) */}
        <path
          d="M 0 844 A 600 600 0 0 0 390 244"
          stroke="currentColor"
          strokeWidth="1"
          fill="none"
          opacity="0.03"
        />
      </svg>
    );
  }

  if (variant === 'loading') {
    // Indicador de carga: arco parcial que rota
    // NO círculo completo, solo segmento diagonal
    return (
      <svg
        className={`animate-spin ${className}`}
        width="32"
        height="32"
        viewBox="0 0 32 32"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-label="Cargando"
      >
        {/* Arco parcial de ~120° alineado diagonalmente */}
        <path
          d="M 28 16 A 12 12 0 0 1 16 28"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
          fill="none"
        />
      </svg>
    );
  }

  if (variant === 'progress') {
    // Stepper: arco parcial que se completa según progreso
    // Progreso de 0-100 dibuja arco de 0° a ~240° (incompleto)
    const angle = (progress / 100) * 240; // Máximo 240° (no completo)
    const startAngle = -135; // Inicia en diagonal superior izquierda
    const endAngle = startAngle + angle;
    
    // Convertir ángulos a coordenadas del arco SVG
    const radius = 14;
    const centerX = 16;
    const centerY = 16;
    
    const startRad = (startAngle * Math.PI) / 180;
    const endRad = (endAngle * Math.PI) / 180;
    
    const x1 = centerX + radius * Math.cos(startRad);
    const y1 = centerY + radius * Math.sin(startRad);
    const x2 = centerX + radius * Math.cos(endRad);
    const y2 = centerY + radius * Math.sin(endRad);
    
    const largeArc = angle > 180 ? 1 : 0;
    
    return (
      <svg
        className={className}
        width="32"
        height="32"
        viewBox="0 0 32 32"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-label={`Progreso: ${Math.round(progress)}%`}
      >
        {/* Arco de fondo (completo al 100%) */}
        <circle
          cx="16"
          cy="16"
          r="14"
          stroke="currentColor"
          strokeWidth="2"
          fill="none"
          opacity="0.1"
          strokeDasharray="88"
          strokeDashoffset="0"
        />
        
        {/* Arco de progreso */}
        {progress > 0 && (
          <path
            d={`M ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2}`}
            stroke="currentColor"
            strokeWidth="2.5"
            strokeLinecap="round"
            fill="none"
          />
        )}
      </svg>
    );
  }

  return null;
}

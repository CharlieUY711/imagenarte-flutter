import { useRef, useState } from 'react';
import { OverlayBox } from './OverlayBox';

interface OverlayDialProps {
  label: string;
  value: number;
  valueText: string; // Texto formateado del valor (ej: "922 px", "35 %")
  min: number;
  max: number;
  step?: number;
  onChange: (value: number) => void; // Preview live (soft)
  onCommit?: (value: number) => void; // Al soltar / confirmar
  isVisible: boolean;
  onClose?: () => void; // Para cerrar al hacer click fuera
}

/**
 * Componente base reutilizable para todos los diales overlay
 * que se superponen sobre la imagen.
 * 
 * IMPORTANTE: Los diales se renderizan DENTRO del OverlayBox estándar.
 * 
 * Características:
 * - UI mínima: label (izquierda), valor (derecha), slider horizontal
 * - Mantiene el fondo transparente del OverlayBox
 * - Ligero e integrado a la imagen
 */
export function OverlayDial({
  label,
  value,
  valueText,
  min,
  max,
  step = 1,
  onChange,
  onCommit,
  isVisible,
  onClose,
}: OverlayDialProps) {
  const [isDragging, setIsDragging] = useState(false);
  const dialRef = useRef<HTMLDivElement>(null);
  const startXRef = useRef<number>(0);
  const startValueRef = useRef<number>(0);

  if (!isVisible) return null;

  // Iniciar arrastre
  const handlePointerDown = (e: React.PointerEvent) => {
    setIsDragging(true);
    startXRef.current = e.clientX;
    startValueRef.current = value;
    e.currentTarget.setPointerCapture(e.pointerId);
    e.preventDefault();
  };

  // Arrastrar
  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDragging || !dialRef.current) return;

    const rect = dialRef.current.getBoundingClientRect();
    const deltaX = e.clientX - startXRef.current;
    const percentageChange = (deltaX / rect.width) * 100;
    
    // Calcular nuevo valor basado en el rango
    const range = max - min;
    const valueChange = (percentageChange / 100) * range;
    const newValue = Math.max(min, Math.min(max, startValueRef.current + valueChange));
    
    // Aplicar step si está definido
    const steppedValue = step > 0 ? Math.round(newValue / step) * step : newValue;
    onChange(steppedValue);
  };

  // Terminar arrastre
  const handlePointerUp = (e: React.PointerEvent) => {
    if (!isDragging) return;
    
    setIsDragging(false);
    e.currentTarget.releasePointerCapture(e.pointerId);
    
    // Llamar onCommit si está definido
    if (onCommit) {
      onCommit(value);
    }
  };

  // Calcular porcentaje para el slider (0-100)
  const percentage = ((value - min) / (max - min)) * 100;

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      {onClose && (
        <div 
          className="absolute inset-0 z-10"
          onClick={onClose}
        />
      )}
      
      {/* Dial overlay - posicionado arriba de la barra blanca */}
      <div 
        className="absolute z-20"
        style={{
          bottom: '33px', // Misma distancia que entre main menu y botón de pixelar rostro
          left: '50%',
          transform: 'translateX(-50%)',
          width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
        }}
      >
        <OverlayBox>
          <div 
            ref={dialRef}
            className="w-full flex items-center gap-3"
            onClick={(e) => e.stopPropagation()}
            onPointerDown={handlePointerDown}
            onPointerMove={handlePointerMove}
            onPointerUp={handlePointerUp}
          >
            {/* Label a la izquierda */}
            <span className="text-xs font-medium text-orange-500 whitespace-nowrap">
              {label}
            </span>
            
            {/* Slider horizontal */}
            <div className="flex-1 relative h-1.5 bg-white/20 rounded-full overflow-hidden" style={{ minWidth: '150px' }}>
              <div 
                className="absolute top-0 left-0 h-full bg-orange-500 transition-all duration-75"
                style={{ width: `${percentage}%` }}
              />
            </div>
            
            {/* Valor a la derecha */}
            <span className="text-xs font-medium text-orange-500 whitespace-nowrap">
              {valueText}
            </span>
          </div>
        </OverlayBox>
      </div>
    </>
  );
}

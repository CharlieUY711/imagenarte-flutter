import { useState, useRef } from 'react';

interface DialButtonProps {
  label: string;
  value: number; // 0-100
  onChange: (value: number) => void;
  unit?: string; // '%' por defecto
  active?: boolean; // Controlado externamente
  onActivate?: () => void; // Notificar activación
}

export function DialButton({ 
  label, 
  value, 
  onChange,
  unit = '%',
  active = false,
  onActivate
}: DialButtonProps) {
  const [isDragging, setIsDragging] = useState(false);
  const dialRef = useRef<HTMLDivElement>(null);
  const startXRef = useRef<number>(0);
  const startValueRef = useRef<number>(0);

  // Activar modo dial
  const handleButtonClick = () => {
    if (!active && onActivate) {
      onActivate();
    }
  };

  // Iniciar arrastre
  const handlePointerDown = (e: React.PointerEvent) => {
    if (!active) return;
    
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
    
    const newValue = Math.max(0, Math.min(100, startValueRef.current + percentageChange));
    onChange(Math.round(newValue));
  };

  // Terminar arrastre
  const handlePointerUp = (e: React.PointerEvent) => {
    if (!isDragging) return;
    
    setIsDragging(false);
    e.currentTarget.releasePointerCapture(e.pointerId);
  };

  return (
    <div 
      ref={dialRef}
      onClick={handleButtonClick}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      className={`
        relative w-full px-3 rounded-sm transition-all duration-300
        h-[33px] flex items-center
        ${active 
          ? 'border-2 border-orange-500 bg-[#1C1C1E] cursor-ew-resize' 
          : 'border-[1px] border-border bg-[#1C1C1E] hover:bg-[#2C2C2E] active:bg-[#2C2C2E] cursor-pointer'
        }
        ${isDragging ? 'ring-2 ring-orange-500/20' : ''}
        select-none touch-none overflow-hidden
      `}
    >
      {!active ? (
        // MODO BOTÓN - Texto centrado
        <div className="w-full flex items-center justify-center">
          <span className="text-xs font-medium text-white">
            {label} {value > 0 && `(${value}${unit})`}
          </span>
        </div>
      ) : (
        // MODO DIAL - Una sola línea
        <div className="w-full flex items-center gap-3">
          <span className="text-xs font-medium text-white whitespace-nowrap">
            {label}
          </span>
          <div className="flex-1 relative h-1.5 bg-muted rounded-full overflow-hidden">
            <div 
              className="absolute top-0 left-0 h-full bg-orange-500 transition-all duration-75"
              style={{ width: `${value}%` }}
            />
          </div>
          <span className="text-xs font-bold text-orange-500 whitespace-nowrap min-w-[3rem] text-right">
            {value}{unit}
          </span>
        </div>
      )}
    </div>
  );
}
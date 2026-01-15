import { useState, useRef } from 'react';
import { Sun, Contrast, Droplet, Sparkles } from 'lucide-react';

interface ClassicAdjustmentsState {
  brightness: number;
  contrast: number;
  saturation: number;
  sharpness: number;
}

interface ClassicAdjustmentsProps {
  values: ClassicAdjustmentsState;
  onChange: (values: ClassicAdjustmentsState) => void;
  active?: boolean; // Controlado externamente
  onActivate?: () => void; // Notificar activación
}

type AdjustmentType = 'brightness' | 'contrast' | 'saturation' | 'sharpness';

const adjustmentConfig = {
  brightness: { icon: Sun, label: 'Brillo' },
  contrast: { icon: Contrast, label: 'Contraste' },
  saturation: { icon: Droplet, label: 'Saturación' },
  sharpness: { icon: Sparkles, label: 'Nitidez' },
};

export function ClassicAdjustments({ values, onChange, active = false, onActivate }: ClassicAdjustmentsProps) {
  const [activeAdjustment, setActiveAdjustment] = useState<AdjustmentType | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const dialRef = useRef<HTMLDivElement>(null);
  const startXRef = useRef<number>(0);
  const startValueRef = useRef<number>(0);

  // Seleccionar ajuste
  const handleSelectAdjustment = (type: AdjustmentType) => {
    setActiveAdjustment(type);
    if (onActivate) onActivate();
  };

  // Cuando se cierra externamente, resetear ajuste interno
  if (!active && activeAdjustment) {
    setActiveAdjustment(null);
  }

  // Iniciar arrastre
  const handlePointerDown = (e: React.PointerEvent) => {
    if (!active || !activeAdjustment) return;
    
    setIsDragging(true);
    startXRef.current = e.clientX;
    startValueRef.current = values[activeAdjustment];
    
    e.currentTarget.setPointerCapture(e.pointerId);
    e.preventDefault();
  };

  // Arrastrar
  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDragging || !activeAdjustment || !dialRef.current) return;

    const rect = dialRef.current.getBoundingClientRect();
    const deltaX = e.clientX - startXRef.current;
    const percentageChange = (deltaX / rect.width) * 100;
    
    const newValue = Math.max(0, Math.min(100, startValueRef.current + percentageChange));
    onChange({
      ...values,
      [activeAdjustment]: Math.round(newValue)
    });
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
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      className={`
        relative w-full px-3 rounded-md border transition-all duration-300
        h-[30px] flex items-center
        ${activeAdjustment 
          ? 'border-2 border-orange-500 bg-[#1C1C1E] cursor-ew-resize' 
          : 'border border-border bg-[#1C1C1E]'
        }
        ${isDragging ? 'ring-2 ring-orange-500/20' : ''}
        select-none touch-none overflow-hidden
      `}
    >
      {!activeAdjustment ? (
        // MODO ICONOS - Grid de 4 iconos con valores si están modificados
        <div className="w-full flex items-center justify-between gap-2">
          <div className="grid grid-cols-4 gap-2 flex-1">
            {(Object.keys(adjustmentConfig) as AdjustmentType[]).map((type) => {
              const { icon: Icon } = adjustmentConfig[type];
              const value = values[type];
              const hasValue = value !== 50; // Diferente del valor neutral
              
              return (
                <button
                  key={type}
                  onClick={() => handleSelectAdjustment(type)}
                  className="flex items-center justify-center gap-1 p-1 rounded-lg hover:bg-[#2C2C2E] active:bg-[#2C2C2E] transition-colors"
                >
                  <Icon 
                    className={`w-4 h-4 ${hasValue ? 'text-orange-500' : 'text-white/40'}`}
                  />
                  {hasValue && (
                    <span className="text-[10px] text-orange-500 font-medium">
                      {value}
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        </div>
      ) : (
        // MODO DIAL - Una sola línea
        <div className="w-full flex items-center gap-3">
          <span className="text-xs font-medium text-white whitespace-nowrap">
            {adjustmentConfig[activeAdjustment].label}
          </span>
          <div className="flex-1 relative h-1.5 bg-muted rounded-full overflow-hidden">
            <div 
              className="absolute top-0 left-0 h-full bg-orange-500 transition-all duration-75"
              style={{ width: `${values[activeAdjustment]}%` }}
            />
          </div>
          <span className="text-xs font-bold text-orange-500 whitespace-nowrap min-w-[3rem] text-right">
            {values[activeAdjustment]}%
          </span>
        </div>
      )}
    </div>
  );
}

export const initialClassicAdjustments: ClassicAdjustmentsState = {
  brightness: 50,
  contrast: 50,
  saturation: 50,
  sharpness: 50,
};
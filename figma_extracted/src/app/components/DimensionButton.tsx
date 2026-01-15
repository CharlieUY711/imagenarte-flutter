import { useState, useRef } from 'react';
import { RectangleVertical, Square, RectangleHorizontal, Circle } from 'lucide-react';

type DimensionType = 'vertical' | 'square' | 'landscape' | 'circular' | null;

interface DimensionButtonProps {
  selectedDimension: DimensionType;
  pixels: number;
  imageDimensions?: { width: number; height: number } | null;
  onDimensionChange: (dimension: DimensionType) => void;
  onPixelsChange: (pixels: number) => void;
  active?: boolean; // Controlado externamente
  onActivate?: () => void; // Notificar activación
}

const dimensionConfig = {
  vertical: { icon: RectangleVertical, label: 'Vertical', ratio: '3:4' },
  square: { icon: Square, label: 'Cuadrada', ratio: '1:1' },
  landscape: { icon: RectangleHorizontal, label: 'Apaisada', ratio: '4:3' },
  circular: { icon: Circle, label: 'Circular', ratio: '1:1' },
};

const dimensions = [
  { type: 'vertical' as const, icon: RectangleVertical },
  { type: 'square' as const, icon: Square },
  { type: 'landscape' as const, icon: RectangleHorizontal },
  { type: 'circular' as const, icon: Circle },
];

export function DimensionButton({ 
  selectedDimension, 
  pixels,
  imageDimensions,
  onDimensionChange,
  onPixelsChange,
  active = false,
  onActivate
}: DimensionButtonProps) {
  const [isDragging, setIsDragging] = useState(false);
  const dialRef = useRef<HTMLDivElement>(null);
  const startXRef = useRef<number>(0);
  const startValueRef = useRef<number>(0);

  // Seleccionar dimensión
  const handleSelectDimension = (type: DimensionType) => {
    onDimensionChange(type);
    if (type && onActivate) {
      onActivate();
    }
  };

  // Iniciar arrastre
  const handlePointerDown = (e: React.PointerEvent) => {
    if (!active || !selectedDimension) return;
    
    setIsDragging(true);
    startXRef.current = e.clientX;
    startValueRef.current = pixels;
    
    e.currentTarget.setPointerCapture(e.pointerId);
    e.preventDefault();
  };

  // Arrastrar
  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDragging || !dialRef.current) return;

    const rect = dialRef.current.getBoundingClientRect();
    const deltaX = e.clientX - startXRef.current;
    const pixelRange = 1800;
    const pixelChange = (deltaX / rect.width) * pixelRange;
    
    const newValue = Math.max(200, Math.min(2000, Math.round(startValueRef.current + pixelChange)));
    onPixelsChange(newValue);
  };

  // Terminar arrastre
  const handlePointerUp = (e: React.PointerEvent) => {
    if (!isDragging) return;
    
    setIsDragging(false);
    e.currentTarget.releasePointerCapture(e.pointerId);
  };

  // Calcular dimensiones reales - usar dimensiones de imagen si están disponibles
  const getActualDimensions = () => {
    if (!selectedDimension) return null;
    
    // Si tenemos dimensiones reales de la imagen, usarlas
    if (imageDimensions) {
      // Para circular, mostrar solo el diámetro en lugar de "ancho x alto"
      if (selectedDimension === 'circular') {
        const diameter = Math.min(imageDimensions.width, imageDimensions.height);
        return `⌀${diameter}`;
      }
      return `${imageDimensions.width}×${imageDimensions.height}`;
    }
    
    // Si no, calcular basándose en la proporción
    switch (selectedDimension) {
      case 'vertical':
        return `${Math.round(pixels * 0.75)}×${pixels}`;
      case 'square':
        return `${pixels}×${pixels}`;
      case 'landscape':
        return `${pixels}×${Math.round(pixels * 0.75)}`;
      case 'circular':
        // Para circular, mostrar solo el diámetro
        return `⌀${pixels}`;
    }
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
        ${active 
          ? 'border-2 border-orange-500 bg-[#1C1C1E] cursor-ew-resize' 
          : 'border border-border bg-[#1C1C1E]'
        }
        ${isDragging ? 'ring-2 ring-orange-500/20' : ''}
        select-none touch-none overflow-hidden
      `}
    >
      {!active ? (
        // MODO ICONOS - Grid de 4 dimensiones
        <div className="w-full flex items-center justify-between gap-2">
          <div className="grid grid-cols-4 gap-2 flex-1">
            {dimensions.map(({ type, icon: Icon }) => {
              const isSelected = selectedDimension === type;
              
              return (
                <button
                  key={type}
                  onClick={() => handleSelectDimension(type)}
                  className="flex items-center justify-center gap-1 p-1 rounded-lg hover:bg-[#2C2C2E] active:bg-[#2C2C2E] transition-colors"
                >
                  <Icon 
                    className={`w-4 h-4 ${isSelected ? 'text-orange-500' : 'text-white/40'}`}
                  />
                  {isSelected && (
                    <span className="text-[10px] text-orange-500 font-medium">
                      {pixels}
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
            {selectedDimension && dimensionConfig[selectedDimension].label}
          </span>
          <div className="flex-1 relative h-1.5 bg-muted rounded-full overflow-hidden">
            <div 
              className="absolute top-0 left-0 h-full bg-orange-500 transition-all duration-75"
              style={{ width: `${((pixels - 200) / 1800) * 100}%` }}
            />
          </div>
          <span className="text-xs font-bold text-orange-500 whitespace-nowrap min-w-[3rem] text-right">
            {getActualDimensions()}
          </span>
        </div>
      )}
    </div>
  );
}
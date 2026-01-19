import { Sun, Contrast, Droplet, Sparkles } from 'lucide-react';
import { OverlayOptionsRow, OverlayOption } from './OverlayOptionsRow';
import { OverlayBox } from './OverlayBox';

export type AdjustmentType = 'brightness' | 'contrast' | 'saturation' | 'sharpness';

interface AdjustmentsOverlayProps {
  onSelect: (adjustment: AdjustmentType) => void;
  onClose: () => void;
}

const adjustments: Array<{ type: AdjustmentType; icon: typeof Sun; label: string }> = [
  { type: 'brightness', icon: Sun, label: 'Brillo' },
  { type: 'contrast', icon: Contrast, label: 'Contraste' },
  { type: 'saturation', icon: Droplet, label: 'Saturación' },
  { type: 'sharpness', icon: Sparkles, label: 'Nitidez' },
];

export function AdjustmentsOverlay({ onSelect, onClose }: AdjustmentsOverlayProps) {
  const options: OverlayOption[] = adjustments.map((adjustment) => {
    const Icon = adjustment.icon;
    return {
      id: adjustment.type,
      label: adjustment.label,
      icon: <Icon className="w-6 h-6" />,
    };
  });

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      <div 
        className="absolute inset-0 z-10"
        onClick={onClose}
      />
      
      {/* Contenedor estándar posicionado arriba de la barra blanca */}
      <div
        className="absolute z-20"
        style={{
          bottom: '33px',
          left: '50%',
          transform: 'translateX(-50%)',
          width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
        }}
      >
        <OverlayBox>
          <OverlayOptionsRow
            title=""
            mode="icon"
            options={options}
            onSelect={(id) => {
              onSelect(id as AdjustmentType);
              onClose();
            }}
            color="white"
            align="space-between"
          />
        </OverlayBox>
      </div>
    </>
  );
}

import { Palette, SlidersHorizontal, Coffee, Circle } from 'lucide-react';
import { OverlayOptionsRow, OverlayOption } from './OverlayOptionsRow';
import { OverlayBox } from './OverlayBox';

export type ColorPreset = 'color' | 'grayscale' | 'sepia' | 'bw';

interface ColorPresetsOverlayProps {
  onSelect: (preset: ColorPreset) => void;
  onClose: () => void;
  selectedPreset?: ColorPreset | null;
}

const presets: Array<{ type: ColorPreset; icon: typeof Palette; label: string }> = [
  { type: 'color', icon: Palette, label: 'Color' },
  { type: 'grayscale', icon: SlidersHorizontal, label: 'Grises' },
  { type: 'sepia', icon: Coffee, label: 'Sepia' },
  { type: 'bw', icon: Circle, label: 'B&N' },
];

export function ColorPresetsOverlay({ onSelect, onClose, selectedPreset }: ColorPresetsOverlayProps) {
  const options: OverlayOption[] = presets.map((preset) => {
    const Icon = preset.icon;
    return {
      id: preset.type,
      label: preset.label,
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
            selectedId={selectedPreset || null}
            onSelect={(id) => onSelect(id as ColorPreset)}
            color="white"
            align="space-between"
          />
        </OverlayBox>
      </div>
    </>
  );
}

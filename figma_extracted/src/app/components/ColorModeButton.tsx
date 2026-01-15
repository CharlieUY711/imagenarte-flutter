import { Palette, SlidersHorizontal, Coffee, Circle } from 'lucide-react';

type ColorMode = 'color' | 'grayscale' | 'sepia' | 'bw' | null;

interface ColorModeButtonProps {
  selectedMode: ColorMode;
  onChange: (mode: ColorMode) => void;
}

const modeConfig = {
  color: { icon: Palette, label: 'Color' },
  grayscale: { icon: SlidersHorizontal, label: 'Grises' },
  sepia: { icon: Coffee, label: 'Sepia' },
  bw: { icon: Circle, label: 'B/N' },
};

export function ColorModeButton({ selectedMode, onChange }: ColorModeButtonProps) {
  return (
    <div 
      className={`
        relative w-full px-3 rounded-md border transition-all duration-300
        h-[30px] flex items-center
        border border-border bg-[#1C1C1E]
      `}
    >
      {/* Grid de 4 opciones - solo iconos */}
      <div className="w-full grid grid-cols-4 gap-2">
        {(Object.keys(modeConfig) as ColorMode[]).map((mode) => {
          if (!mode) return null;
          const { icon: Icon } = modeConfig[mode];
          const isSelected = selectedMode === mode;
          
          return (
            <button
              key={mode}
              onClick={() => onChange(mode)}
              className="flex items-center justify-center p-1 rounded-lg transition-colors"
            >
              <Icon 
                className={`w-4 h-4 transition-colors ${
                  isSelected 
                    ? 'text-orange-500' 
                    : 'text-white/40'
                }`}
              />
            </button>
          );
        })}
      </div>
    </div>
  );
}
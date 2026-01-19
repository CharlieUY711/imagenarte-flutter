import { OverlayOptionsRow, OverlayOption } from './OverlayOptionsRow';
import { OverlayBox } from './OverlayBox';

interface IncludeExcludeOverlayProps {
  onInclude: () => void;
  onExclude: () => void;
  onCancel: () => void;
  selectedMode?: 'include' | 'exclude' | null;
}

export function IncludeExcludeOverlay({ onInclude, onExclude, onCancel, selectedMode }: IncludeExcludeOverlayProps) {
  const options: OverlayOption[] = [
    { id: 'include', label: 'INTERIOR' },
    { id: 'exclude', label: 'EXTERIOR' },
  ];

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      <div 
        className="absolute inset-0 z-10"
        onClick={onCancel}
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
            title="Modo de selección"
            mode="text"
            options={options}
            selectedId={selectedMode || null}
            onSelect={(id) => {
              if (id === 'include') {
                onInclude();
              } else {
                onExclude();
              }
            }}
            color="white"
          />
        </OverlayBox>
      </div>
    </>
  );
}

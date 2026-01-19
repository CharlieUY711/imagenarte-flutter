import { OverlayOptionsRow, OverlayOption } from './OverlayOptionsRow';
import { OverlayBox } from './OverlayBox';

/**
 * Overlay de decisión para pixelado de rostro
 * Usa OverlayOptionsRow estándar: Automática | Manual
 */
interface FacePixelateDecisionOverlayProps {
  onAccept: () => void;
  onManual: () => void;
  onClose?: () => void;
}

export function FacePixelateDecisionOverlay({
  onAccept,
  onManual,
  onClose,
}: FacePixelateDecisionOverlayProps) {
  const options: OverlayOption[] = [
    { id: 'auto', label: 'Automática' },
    { id: 'manual', label: 'Manual' },
  ];

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      {onClose && (
        <div 
          className="absolute inset-0 z-10"
          onClick={onClose}
        />
      )}
      
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
            title="Tipo de selección"
            mode="text"
            options={options}
            onSelect={(id) => {
              if (id === 'auto') {
                onAccept();
              } else {
                onManual();
              }
            }}
            color="white"
          />
        </OverlayBox>
      </div>
    </>
  );
}

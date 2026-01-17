import { OverlayOptionsRow, OverlayOption } from './OverlayOptionsRow';
import { OverlayBox } from './OverlayBox';

/**
 * Overlay de repetición para pixelado de rostro
 * Usa OverlayOptionsRow estándar: Sí | No
 */
interface FacePixelateRepeatOverlayProps {
  onYes: () => void;
  onNo: () => void;
}

export function FacePixelateRepeatOverlay({
  onYes,
  onNo,
}: FacePixelateRepeatOverlayProps) {
  const options: OverlayOption[] = [
    { id: 'yes', label: 'Sí' },
    { id: 'no', label: 'No' },
  ];

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      <div 
        className="absolute inset-0 z-10"
        onClick={onNo}
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
            title="¿Desea pixelar otra área?"
            mode="text"
            options={options}
            onSelect={(id) => {
              if (id === 'yes') {
                onYes();
              } else {
                onNo();
              }
            }}
            color="white"
          />
        </OverlayBox>
      </div>
    </>
  );
}

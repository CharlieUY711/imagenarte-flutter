import { OverlayBox } from './OverlayBox';

interface ScissorsDecisionOverlayProps {
  onInterior: () => void;
  onExterior: () => void;
  onCancel: () => void;
}

/**
 * Overlay para la herramienta Tijera
 * Muestra opciones: Interior, Exterior, Cancelar
 * Pregunta: "¿Con cuál te quedás?"
 */
export function ScissorsDecisionOverlay({ 
  onInterior, 
  onExterior, 
  onCancel 
}: ScissorsDecisionOverlayProps) {
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
          width: 'calc(100% - 32px)',
        }}
      >
        <OverlayBox>
          <div className="w-full flex items-center gap-2">
            {/* Título en naranja */}
            <span className="text-orange-500 text-sm font-medium whitespace-nowrap flex-shrink-0">
              ¿Con cuál te quedás?:
            </span>

            {/* Opciones */}
            <div className="flex items-center gap-3 flex-1 justify-start">
              <button
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  onInterior();
                }}
                className="text-sm font-medium hover:opacity-80 transition-opacity px-1.5 py-1 flex items-center whitespace-nowrap text-white opacity-80"
              >
                Interior
              </button>
              
              <button
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  onExterior();
                }}
                className="text-sm font-medium hover:opacity-80 transition-opacity px-1.5 py-1 flex items-center whitespace-nowrap text-white opacity-80"
              >
                Exterior
              </button>

              <button
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  onCancel();
                }}
                className="text-sm font-medium hover:opacity-80 transition-opacity px-1.5 py-1 flex items-center whitespace-nowrap text-white opacity-80 ml-auto"
              >
                Cancelar
              </button>
            </div>
          </div>
        </OverlayBox>
      </div>
    </>
  );
}

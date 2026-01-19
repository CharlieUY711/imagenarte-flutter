import { ReactNode } from 'react';

export interface OverlayOption {
  id: string;
  label?: string;
  icon?: ReactNode;
}

interface OverlayOptionsRowProps {
  title?: string; // Opcional: Título visible en naranja (si está vacío o no se proporciona, no se muestra)
  mode: 'icon' | 'text';
  options: OverlayOption[];
  selectedId?: string | null;
  onSelect: (id: string) => void;
  onClose?: () => void;
  align?: 'center' | 'space-between';
  color?: 'white' | 'orange';
}

/**
 * Componente estándar reutilizable para todos los overlays de opciones
 * que se superponen sobre la imagen.
 * 
 * IMPORTANTE: Este componente debe usarse DENTRO de OverlayBox.
 * El OverlayBox maneja el posicionamiento y el estilo visual.
 * 
 * ESTÁNDAR GLOBAL DEFINITIVO:
 * - Título OBLIGATORIO en color NARANJA a la izquierda
 * - Opciones a la derecha en una sola línea
 * - Título siempre visible para contexto
 * - Colores: Título → NARANJA, Opciones no seleccionadas → BLANCO, Opción seleccionada → NARANJA
 * - Sin backgrounds, borders, cards ni chips
 * - El color es el ÚNICO indicador de estado
 */
export function OverlayOptionsRow({
  title,
  mode,
  options,
  selectedId,
  onSelect,
  onClose,
  align,
  color = 'white',
}: OverlayOptionsRowProps) {
  // Título es opcional ahora
  const showTitle = title && title.trim() !== '';

  // Validación: modo text requiere exactamente 2 opciones
  if (mode === 'text' && options.length !== 2) {
    console.warn('OverlayOptionsRow: modo "text" requiere exactamente 2 opciones');
    return null;
  }

  // Colores según estándar: título siempre naranja, opciones según estado
  const titleColor = 'text-orange-500'; // Título siempre naranja
  const optionUnselectedColor = 'text-white'; // Opciones no seleccionadas siempre blancas
  const optionSelectedColor = 'text-orange-500'; // Opción seleccionada siempre naranja

  return (
    <div 
      className="w-full flex items-center gap-2"
      onClick={(e) => e.stopPropagation()}
    >
      {/* Título opcional en naranja a la izquierda */}
      {showTitle && (
        <span className={`${titleColor} text-sm font-medium whitespace-nowrap flex-shrink-0`}>
          {title}:
        </span>
      )}

      {/* Opciones a la derecha */}
      <div className={`flex items-center flex-1 ${
        mode === 'icon' 
          ? (align === 'space-between' ? 'justify-between' : 'justify-center gap-2') 
          : 'gap-3 justify-start'
      }`}>
        {mode === 'icon' ? (
          // Modo icono: iconos con labels opcionales
          options.map((option) => {
            const isSelected = selectedId === option.id;
            const hasIcon = !!option.icon;
            const hasLabel = !!option.label;
            
            console.log('[OverlayOptionsRow] Rendering button for id:', option.id);
            
            return (
              <button
                key={option.id}
                type="button"
                onMouseDown={(e) => {
                  console.log('[OverlayOptionsRow] Button onMouseDown, id:', option.id);
                  e.preventDefault();
                  e.stopPropagation();
                  console.log('[OverlayOptionsRow] Calling onSelect from onMouseDown, id:', option.id);
                  onSelect(option.id);
                  if (onClose) onClose();
                }}
                onClick={(e) => {
                  console.log('[OverlayOptionsRow] Button onClick triggered, id:', option.id);
                  e.preventDefault();
                  e.stopPropagation();
                }}
                className={`${hasIcon && hasLabel ? 'flex flex-col items-center gap-1.5' : 'flex items-center justify-center'} px-3 py-1.5 hover:opacity-80 transition-opacity min-w-[44px] min-h-[44px] flex-1`}
              >
                {option.icon && (
                  <div className={`w-6 h-6 flex items-center justify-center ${isSelected ? optionSelectedColor : optionUnselectedColor} ${isSelected ? 'opacity-100' : 'opacity-80'}`}>
                    {option.icon}
                  </div>
                )}
                {option.label && (
                  <span className={`${hasIcon ? 'text-xs' : 'text-sm'} font-medium ${isSelected ? optionSelectedColor : optionUnselectedColor} ${isSelected ? 'opacity-100 font-bold' : 'opacity-80'}`}>
                    {option.label}
                  </span>
                )}
              </button>
            );
          })
        ) : (
          // Modo texto: 2 opciones en línea
          <>
            <button
              onClick={() => {
                onSelect(options[0].id);
                if (onClose) onClose();
              }}
              className={`text-sm font-medium hover:opacity-80 transition-opacity px-1.5 py-1 flex items-center whitespace-nowrap ${
                selectedId === options[0].id 
                  ? `${optionSelectedColor} opacity-100 font-bold` 
                  : `${optionUnselectedColor} opacity-80`
              }`}
            >
              {options[0].label}
            </button>
            
            <button
              onClick={() => {
                onSelect(options[1].id);
                if (onClose) onClose();
              }}
              className={`text-sm font-medium hover:opacity-80 transition-opacity px-1.5 py-1 flex items-center whitespace-nowrap ${
                selectedId === options[1].id 
                  ? `${optionSelectedColor} opacity-100 font-bold` 
                  : `${optionUnselectedColor} opacity-80`
              }`}
            >
              {options[1].label}
            </button>
          </>
        )}
      </div>
    </div>
  );
}

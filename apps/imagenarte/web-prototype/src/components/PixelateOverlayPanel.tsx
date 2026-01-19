import React from 'react';
import { useEditor } from '../context/EditorContext';
import { EditorOverlayPanel } from './EditorOverlayPanel';
import { OverlayDialRow } from './OverlayDialRow';

/**
 * Panel overlay para pixelado con slider de intensidad
 * 
 * Sigue el mismo patrón que BlurOverlayPanel:
 * - Título: "Pixelado"
 * - Slider de intensidad (2px → 50px, mapeado a 0-100)
 * - Solo visible cuando activeContext === 'action_pixelate'
 * - Deshabilitado si no hay ROI activo
 */
export const PixelateOverlayPanel: React.FC = () => {
  const { 
    activeContext, 
    pixelateIntensity, 
    setPixelateIntensity, 
    hasValidSelection,
    pushUndo 
  } = useEditor();

  const isVisible = activeContext === 'action_pixelate';

  // Mapear intensidad de 0-100 a tamaño de bloque 2-50px
  const blockSize = 2 + (pixelateIntensity / 100) * 48; // 2px a 50px

  return (
    <EditorOverlayPanel visible={isVisible}>
      <OverlayDialRow
        label="Pixelado"
        value={pixelateIntensity}
        min={0}
        max={100}
        formatValue={(val) => `${Math.round(blockSize)}px`}
        disabled={!hasValidSelection}
        onChange={(value) => {
          if (hasValidSelection) {
            setPixelateIntensity(value);
          }
        }}
        onChangeEnd={(value) => {
          if (hasValidSelection) {
            setPixelateIntensity(value);
            pushUndo();
          }
        }}
      />
    </EditorOverlayPanel>
  );
};

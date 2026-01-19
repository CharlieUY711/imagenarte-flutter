import React from 'react';

interface EditorOverlayPanelProps {
  visible: boolean;
  children: React.ReactNode;
}

/**
 * Panel overlay canónico reutilizable para todas las herramientas del editor
 * 
 * Posición: sobre el canvas, alineado abajo, justo encima de la toolbar
 * No empuja el layout (usa position: absolute)
 */
export const EditorOverlayPanel: React.FC<EditorOverlayPanelProps> = ({
  visible,
  children,
}) => {
  if (!visible) {
    return null;
  }

  return (
    <div
      style={{
        position: 'absolute',
        left: '16px',
        right: '16px',
        bottom: '80px', // Toolbar height + gap
        padding: '12px',
        backgroundColor: 'rgba(0, 0, 0, 0.7)',
        borderRadius: '8px',
        pointerEvents: 'auto',
      }}
    >
      {children}
    </div>
  );
};

import React from 'react';
import { useEditor } from '../context/EditorContext';

/**
 * Botón de undo
 * 
 * Siempre visible, deshabilitado cuando no hay acciones para deshacer
 */
export const UndoButton: React.FC = () => {
  const { undo, canUndo } = useEditor();

  return (
    <button
      onClick={undo}
      disabled={!canUndo}
      style={{
        padding: '8px 16px',
        backgroundColor: canUndo ? 'white' : 'rgba(255, 255, 255, 0.5)',
        borderRadius: '4px',
        border: 'none',
        cursor: canUndo ? 'pointer' : 'not-allowed',
        fontSize: '14px',
        fontWeight: 500,
      }}
    >
      ↶ Undo
    </button>
  );
};

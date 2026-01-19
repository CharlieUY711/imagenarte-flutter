import { useState, useCallback } from 'react';

export interface EditorSnapshot {
  activeTool: 'select' | 'pointer' | null;
  pixelateValue: number;
  blurValue: number;
  cropIntensity: number;
  activePreset?: string | null;
  activeControl?: 'pixelate' | 'blur' | 'crop' | 'dimension' | 'adjustments' | null;
  // Agregar otros campos según sea necesario
  [key: string]: any;
}

const MAX_HISTORY = 5;

export function useEditorHistory(initialSnapshot?: EditorSnapshot) {
  const [history, setHistory] = useState<EditorSnapshot[]>(
    initialSnapshot ? [initialSnapshot] : []
  );
  const [historyIndex, setHistoryIndex] = useState<number>(
    initialSnapshot ? 0 : -1
  );

  const pushSnapshot = useCallback((snapshot: EditorSnapshot) => {
    setHistory((prevHistory) => {
      // No duplicar snapshots iguales
      const lastSnapshot = prevHistory[prevHistory.length - 1];
      if (lastSnapshot && JSON.stringify(lastSnapshot) === JSON.stringify(snapshot)) {
        return prevHistory;
      }

      // Eliminar estados futuros si estamos en medio del historial
      const newHistory = prevHistory.slice(0, historyIndex + 1);

      // Agregar nuevo estado
      newHistory.push(snapshot);

      // Limitar a MAX_HISTORY niveles
      if (newHistory.length > MAX_HISTORY) {
        newHistory.shift(); // Eliminar el más antiguo
        setHistoryIndex(MAX_HISTORY - 1);
      } else {
        setHistoryIndex(newHistory.length - 1);
      }

      return newHistory;
    });
  }, [historyIndex]);

  const undo = useCallback((): EditorSnapshot | null => {
    if (historyIndex > 0) {
      const previousState = history[historyIndex - 1];
      setHistoryIndex(historyIndex - 1);
      return previousState;
    }
    return null;
  }, [history, historyIndex]);

  const canUndo = historyIndex > 0;
  const hasChanges = canUndo;

  return {
    history,
    historyIndex,
    canUndo,
    hasChanges,
    pushSnapshot,
    undo,
    historyCount: historyIndex,
  };
}

import React, { createContext, useContext } from 'react';
import { useEditorState } from '../hooks/useEditorState';

type EditorContextType = ReturnType<typeof useEditorState>;

const EditorContext = createContext<EditorContextType | null>(null);

/**
 * Provider del contexto del editor
 * 
 * Proporciona el estado global del editor a todos los componentes hijos
 */
export const EditorProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const editorState = useEditorState();

  return (
    <EditorContext.Provider value={editorState}>
      {children}
    </EditorContext.Provider>
  );
};

/**
 * Hook para acceder al contexto del editor
 */
export const useEditor = (): EditorContextType => {
  const context = useContext(EditorContext);
  if (!context) {
    throw new Error('useEditor must be used within EditorProvider');
  }
  return context;
};

import React from 'react';
import { EditorProvider } from './context/EditorContext';
import { EditorCanvas } from './components/EditorCanvas';
import { PixelateOverlayPanel } from './components/PixelateOverlayPanel';
import { UndoButton } from './components/UndoButton';

/**
 * Componente principal de la aplicación
 * 
 * Integra:
 * - Canvas con renderizado de imagen y pixelado
 * - Panel overlay de pixelado
 * - Botón de undo
 */
function App() {
  const [imageUrl, setImageUrl] = React.useState<string | null>(null);

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setImageUrl(url);
    }
  };

  return (
    <EditorProvider>
      <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
        {/* Toolbar superior */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            height: '60px',
            backgroundColor: '#FF6B35',
            display: 'flex',
            alignItems: 'center',
            padding: '0 16px',
            gap: '16px',
            zIndex: 1000,
          }}
        >
          <input
            type="file"
            accept="image/*"
            onChange={handleImageUpload}
            style={{ display: 'none' }}
            id="image-upload"
          />
          <label
            htmlFor="image-upload"
            style={{
              padding: '8px 16px',
              backgroundColor: 'white',
              borderRadius: '4px',
              cursor: 'pointer',
            }}
          >
            Cargar Imagen
          </label>
          <UndoButton />
        </div>

        {/* Canvas */}
        <div
          style={{
            position: 'absolute',
            top: '60px',
            left: 0,
            right: 0,
            bottom: '80px', // Espacio para toolbar inferior
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: '#1a1a1a',
          }}
        >
          {imageUrl ? (
            <EditorCanvas imageUrl={imageUrl} />
          ) : (
            <div style={{ color: 'white' }}>Carga una imagen para comenzar</div>
          )}
        </div>

        {/* Overlay Panel */}
        <PixelateOverlayPanel />

        {/* Toolbar inferior (placeholder) */}
        <div
          style={{
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
            height: '80px',
            backgroundColor: '#FF6B35',
            zIndex: 1000,
          }}
        />
      </div>
    </EditorProvider>
  );
}

export default App;

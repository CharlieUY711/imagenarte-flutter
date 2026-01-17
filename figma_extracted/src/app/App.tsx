import { useState, useEffect } from 'react';
import { DialDemo } from '@/app/screens/DialDemo';
import { TransformPlayground } from '@/app/screens/TransformPlayground';

export default function App() {
  const [imageUrl, setImageUrl] = useState<string>('');
  const [selectedImageFile, setSelectedImageFile] = useState<File | null>(null);
  const [showPlayground, setShowPlayground] = useState(false);

  // Toggle para playground (desde URL)
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('playground') === 'true' || window.location.pathname === '/transform-playground') {
      setShowPlayground(true);
    }
  }, []);

  const handleImageSelect = (file: File) => {
    setSelectedImageFile(file);
    const url = URL.createObjectURL(file);
    setImageUrl(url);
  };

  const handleVideoSelect = (file: File) => {
    // TODO: Implementar video en el futuro
    console.log('Video seleccionado:', file.name);
  };

  const handleBack = () => {
    if (imageUrl) {
      URL.revokeObjectURL(imageUrl);
      setImageUrl('');
    }
    setSelectedImageFile(null);
  };

  // Si está en modo playground, mostrar solo el playground
  if (showPlayground) {
    return <TransformPlayground />;
  }

  return (
    <div className="w-full bg-white min-h-screen flex items-center justify-center p-4">
      {/* Botón de acceso rápido al playground (solo en dev) */}
      {process.env.NODE_ENV === 'development' && (
        <button
          onClick={() => setShowPlayground(true)}
          className="fixed top-4 right-4 z-50 bg-orange-500 text-white px-4 py-2 rounded text-sm font-medium hover:bg-orange-600"
          style={{ zIndex: 9999 }}
        >
          🧪 Transform Playground
        </button>
      )}
      
      <div 
        className="bg-black"
        style={{ 
          transform: 'scale(0.81)',
          transformOrigin: 'center center',
          width: '100%',
          maxWidth: '390px',
          margin: 0,
          padding: 0
        }}
      >
        <DialDemo
          imageUrl={imageUrl}
          onImageSelect={handleImageSelect}
          onVideoSelect={handleVideoSelect}
          onBack={handleBack}
        />
      </div>
    </div>
  );
}
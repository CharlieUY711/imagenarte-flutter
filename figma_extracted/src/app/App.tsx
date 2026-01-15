import { useState } from 'react';
import { DialDemo } from '@/app/screens/DialDemo';

export default function App() {
  const [imageUrl, setImageUrl] = useState<string>('');
  const [selectedImageFile, setSelectedImageFile] = useState<File | null>(null);

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

  return (
    <div className="w-full bg-white min-h-screen flex items-center justify-center p-4">
      <div 
        className="bg-black"
        style={{ 
          transform: 'scale(0.9)',
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
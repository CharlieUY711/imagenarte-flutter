import { useRef } from 'react';
import { Button } from '@/app/components/Button';
import { Stepper } from '@/app/components/Stepper';
import { ImagePreview } from '@/app/components/ImagePreview';
import { ArrowLeft } from 'lucide-react';

interface WizardStep1Props {
  selectedImage: string | null;
  onImageSelect: (file: File) => void;
  onBack: () => void;
  onNext: () => void;
}

export function WizardStep1({ selectedImage, onImageSelect, onBack, onNext }: WizardStep1Props) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file && file.type.startsWith('image/')) {
      onImageSelect(file);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <div className="border-b border-border">
        <div className="flex items-center px-4 py-3">
          <button
            onClick={onBack}
            className="p-2 -ml-2 hover:bg-accent rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div className="flex-1">
            <Stepper currentStep={1} totalSteps={3} />
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 px-6 py-6 space-y-6">
        <div className="space-y-2">
          <h2 className="text-xl font-medium">Seleccioná una imagen</h2>
        </div>

        <ImagePreview
          src={selectedImage}
          state={selectedImage ? 'loaded' : 'empty'}
          className="max-w-md mx-auto"
        />

        <div className="flex justify-center">
          <Button
            variant="secondary"
            onClick={() => fileInputRef.current?.click()}
          >
            Elegir imagen
          </Button>
        </div>

        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileChange}
          className="hidden"
        />
      </div>

      {/* Footer */}
      <div className="border-t border-border px-6 py-4">
        <Button
          variant="primary"
          onClick={onNext}
          disabled={!selectedImage}
          className="w-full"
        >
          Siguiente
        </Button>
      </div>
    </div>
  );
}

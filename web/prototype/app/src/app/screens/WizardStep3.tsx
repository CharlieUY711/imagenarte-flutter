import { Button } from '@/app/components/Button';
import { Stepper } from '@/app/components/Stepper';
import { ImagePreview } from '@/app/components/ImagePreview';
import { SectionCard } from '@/app/components/SectionCard';
import { ArrowLeft } from 'lucide-react';
import { ActionsState } from './WizardStep2';

interface WizardStep3Props {
  selectedImage: string | null;
  actions: ActionsState;
  onBack: () => void;
  onNext: () => void;
}

export function WizardStep3({ selectedImage, actions, onBack, onNext }: WizardStep3Props) {
  const activeActions: string[] = [];
  
  if (actions.pixelate.enabled) {
    activeActions.push(`Pixelar rostro (intensidad ${actions.pixelate.intensity})`);
  }
  if (actions.blur.enabled) {
    activeActions.push(`Blur selectivo (intensidad ${actions.blur.intensity})`);
  }
  if (actions.crop.enabled) {
    activeActions.push(`Crop ${actions.crop.aspectRatio}`);
  }

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
            <Stepper currentStep={3} totalSteps={3} />
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 px-6 py-6 space-y-6 overflow-y-auto">
        <div className="space-y-2">
          <h2 className="text-xl font-medium">Vista previa</h2>
        </div>

        <ImagePreview
          src={selectedImage}
          state={selectedImage ? 'loaded' : 'empty'}
          className="max-w-md mx-auto"
        />
        
        <p className="text-sm text-muted-foreground text-center">
          Vista previa. El procesamiento final ocurre al exportar.
        </p>

        <SectionCard title="Operaciones activas">
          {activeActions.length > 0 ? (
            <ul className="space-y-2">
              {activeActions.map((action, index) => (
                <li key={index} className="text-sm flex items-start gap-2">
                  <span className="text-primary mt-0.5">•</span>
                  <span>{action}</span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-sm text-muted-foreground">
              No activaste ninguna acción (opcional).
            </p>
          )}
        </SectionCard>
      </div>

      {/* Footer */}
      <div className="border-t border-border px-6 py-4">
        <Button
          variant="primary"
          onClick={onNext}
          className="w-full"
        >
          Continuar a exportación
        </Button>
      </div>
    </div>
  );
}

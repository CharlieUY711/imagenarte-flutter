import { Button } from '@/app/components/Button';
import { Stepper } from '@/app/components/Stepper';
import { Toggle } from '@/app/components/Toggle';
import { Slider } from '@/app/components/Slider';
import { Dropdown } from '@/app/components/Dropdown';
import { SectionCard } from '@/app/components/SectionCard';
import { ArrowLeft } from 'lucide-react';

export interface ActionsState {
  pixelate: {
    enabled: boolean;
    intensity: number;
  };
  blur: {
    enabled: boolean;
    intensity: number;
  };
  removeBackground: {
    enabled: boolean;
  };
  crop: {
    enabled: boolean;
    aspectRatio: '1:1' | '4:3' | '16:9' | '9:16';
  };
}

interface WizardStep2Props {
  actions: ActionsState;
  onActionsChange: (actions: ActionsState) => void;
  onBack: () => void;
  onNext: () => void;
}

const ASPECT_RATIO_OPTIONS = [
  { value: '1:1', label: '1:1 (Cuadrado)' },
  { value: '4:3', label: '4:3 (Clásico)' },
  { value: '16:9', label: '16:9 (Horizontal)' },
  { value: '9:16', label: '9:16 (Vertical)' },
];

export function WizardStep2({ actions, onActionsChange, onBack, onNext }: WizardStep2Props) {
  const updateAction = <K extends keyof ActionsState>(
    action: K,
    updates: Partial<ActionsState[K]>
  ) => {
    onActionsChange({
      ...actions,
      [action]: { ...actions[action], ...updates },
    });
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
            <Stepper currentStep={2} totalSteps={3} />
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 px-6 py-6 space-y-6 overflow-y-auto">
        <div className="space-y-2">
          <h2 className="text-xl font-medium">Acciones</h2>
        </div>

        <SectionCard>
          <Toggle
            label="Pixelar rostro"
            checked={actions.pixelate.enabled}
            onCheckedChange={(enabled) => updateAction('pixelate', { enabled })}
            id="toggle-pixelate"
          />
          
          {actions.pixelate.enabled && (
            <Slider
              label="Intensidad"
              value={actions.pixelate.intensity}
              onValueChange={(intensity) => updateAction('pixelate', { intensity })}
              min={1}
              max={10}
            />
          )}
        </SectionCard>

        <SectionCard>
          <Toggle
            label="Blur selectivo"
            checked={actions.blur.enabled}
            onCheckedChange={(enabled) => updateAction('blur', { enabled })}
            id="toggle-blur"
          />
          
          {actions.blur.enabled && (
            <Slider
              label="Intensidad"
              value={actions.blur.intensity}
              onValueChange={(intensity) => updateAction('blur', { intensity })}
              min={1}
              max={10}
            />
          )}
        </SectionCard>

        <SectionCard>
          <Toggle
            label="Quitar fondo"
            subtitle="(próximamente)"
            checked={actions.removeBackground.enabled}
            onCheckedChange={(enabled) => updateAction('removeBackground', { enabled })}
            disabled
            id="toggle-remove-bg"
          />
        </SectionCard>

        <SectionCard>
          <Toggle
            label="Crop inteligente"
            checked={actions.crop.enabled}
            onCheckedChange={(enabled) => updateAction('crop', { enabled })}
            id="toggle-crop"
          />
          
          {actions.crop.enabled && (
            <Dropdown
              label="Aspecto"
              value={actions.crop.aspectRatio}
              onValueChange={(value) => updateAction('crop', { aspectRatio: value as ActionsState['crop']['aspectRatio'] })}
              options={ASPECT_RATIO_OPTIONS}
            />
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
          Siguiente
        </Button>
      </div>
    </div>
  );
}

import { ArrowLeft } from 'lucide-react';
import { useState } from 'react';
import { Button } from '@/app/components/Button';
import { Toggle } from '@/app/components/Toggle';
import { Slider } from '@/app/components/Slider';
import { Dropdown } from '@/app/components/Dropdown';
import { CollapsibleSection } from '@/app/components/CollapsibleSection';
import { DialButton } from '@/app/components/DialButton';
import { ClassicAdjustments, initialClassicAdjustments } from '@/app/components/ClassicAdjustments';
import { ActionsStateMVP } from '@/app/types/actions';

interface WizardActionsProps {
  imageFile: File;
  imageUrl: string;
  actions: ActionsStateMVP;
  onActionsChange: (actions: ActionsStateMVP) => void;
  onBack: () => void;
  onContinue: () => void;
}

export function WizardActions({
  imageFile,
  imageUrl,
  actions,
  onActionsChange,
  onBack,
  onContinue,
}: WizardActionsProps) {
  const [classicAdjustments, setClassicAdjustments] = useState(initialClassicAdjustments);

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <div className="flex items-center gap-3 p-4 border-b border-border">
        <button
          onClick={onBack}
          className="p-2 -ml-2 rounded-lg active:bg-muted transition-colors"
          aria-label="Volver"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-lg font-medium">Tratamiento de imagen</h1>
      </div>

      {/* PREVIEW DE IMAGEN - Zona superior (SIEMPRE VISIBLE, IMAGEN ORIGINAL) */}
      <div 
        className="relative bg-muted border-b border-border" 
        style={{ height: '45vh', minHeight: '280px' }}
      >
        <img 
          src={imageUrl} 
          alt="Imagen original seleccionada" 
          className="w-full h-full object-contain"
        />
        
        {/* Nota UX obligatoria (solo visible en diseño, oculta en producción) */}
        <div className="absolute bottom-2 left-2 right-2 bg-background/90 backdrop-blur-sm p-2 text-xs text-muted-foreground rounded border border-border">
          <p className="font-medium mb-1">Nota de diseño UX:</p>
          <p>La imagen permanece fija como referencia visual. El procesamiento real ocurre en la pantalla de Export. No hay preview procesado en tiempo real en este paso.</p>
        </div>
      </div>

      {/* PANEL DE ACCIONES - Zona inferior (dinámico, scrollable) */}
      <div className="flex-1 flex flex-col bg-background">
        <div className="flex-1 overflow-y-auto">
          {/* 1. Pixelar rostro */}
          <CollapsibleSection title="Pixelar rostro">
            <Toggle
              label="Activar pixelado de rostro"
              checked={actions.pixelate.enabled}
              onChange={(checked) => 
                onActionsChange({
                  ...actions,
                  pixelate: { ...actions.pixelate, enabled: checked }
                })
              }
            />
            <p className="text-sm text-muted-foreground mt-2">
              Protege la identidad pixelando rostros detectados.
            </p>
            
            {actions.pixelate.enabled && (
              <div className="mt-3">
                <Slider
                  label={`Intensidad: ${actions.pixelate.intensity}`}
                  min={1}
                  max={10}
                  step={1}
                  value={actions.pixelate.intensity}
                  onChange={(value) =>
                    onActionsChange({
                      ...actions,
                      pixelate: { ...actions.pixelate, intensity: value }
                    })
                  }
                />
              </div>
            )}
          </CollapsibleSection>

          {/* 2. Blur selectivo */}
          <CollapsibleSection title="Blur selectivo">
            <Toggle
              label="Activar blur selectivo"
              checked={actions.blur.enabled}
              onChange={(checked) =>
                onActionsChange({
                  ...actions,
                  blur: { ...actions.blur, enabled: checked }
                })
              }
            />
            <p className="text-sm text-muted-foreground mt-2">
              Difumina áreas sensibles de la imagen.
            </p>
            
            {actions.blur.enabled && (
              <div className="mt-3">
                <Slider
                  label={`Intensidad: ${actions.blur.intensity}`}
                  min={1}
                  max={10}
                  step={1}
                  value={actions.blur.intensity}
                  onChange={(value) =>
                    onActionsChange({
                      ...actions,
                      blur: { ...actions.blur, intensity: value }
                    })
                  }
                />
              </div>
            )}
          </CollapsibleSection>

          {/* 3. Crop inteligente */}
          <CollapsibleSection title="Crop inteligente">
            <Toggle
              label="Activar recorte"
              checked={actions.crop.enabled}
              onChange={(checked) =>
                onActionsChange({
                  ...actions,
                  crop: { ...actions.crop, enabled: checked }
                })
              }
            />
            <p className="text-sm text-muted-foreground mt-2">
              Recorta la imagen según el ratio seleccionado.
            </p>
            
            {actions.crop.enabled && (
              <div className="mt-3">
                <Dropdown
                  label="Ratio de aspecto"
                  value={actions.crop.ratio}
                  onChange={(value) =>
                    onActionsChange({
                      ...actions,
                      crop: { 
                        ...actions.crop, 
                        ratio: value as '1:1' | '16:9' | '4:3' | '9:16'
                      }
                    })
                  }
                  options={[
                    { value: '1:1', label: '1:1 (Cuadrado)' },
                    { value: '16:9', label: '16:9 (Widescreen)' },
                    { value: '4:3', label: '4:3 (Clásico)' },
                    { value: '9:16', label: '9:16 (Vertical)' },
                  ]}
                />
              </div>
            )}
          </CollapsibleSection>

          {/* 4. Quitar fondo (DISABLED) */}
          <CollapsibleSection title="Quitar fondo">
            <div className="opacity-50 pointer-events-none">
              <Toggle
                label="Activar remoción de fondo"
                checked={false}
                onChange={() => {}}
              />
            </div>
            <p className="text-sm text-muted-foreground mt-2 flex items-center gap-2">
              <span className="font-medium text-foreground">(Próximamente)</span>
              Esta función estará disponible en una futura actualización.
            </p>
          </CollapsibleSection>

          {/* 5. Ajustes clásicos */}
          <CollapsibleSection title="Ajustes clásicos">
            <ClassicAdjustments
              values={classicAdjustments}
              onChange={setClassicAdjustments}
            />
          </CollapsibleSection>
        </div>

        {/* Botón Continuar (fijo en la parte inferior) */}
        <div className="p-4 border-t border-border bg-background">
          <Button
            variant="primary"
            onClick={onContinue}
            className="w-full"
          >
            Continuar
          </Button>
        </div>
      </div>
    </div>
  );
}
import { Button } from '@/app/components/Button';
import { RadialMotif } from '@/app/components/RadialMotif';

interface HomeProps {
  onStartImageFlow: () => void;
  onDialDemo?: () => void;
}

export function Home({ onStartImageFlow, onDialDemo }: HomeProps) {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-6 bg-background relative">
      {/* Motivo de identidad visual - background sutil */}
      <RadialMotif variant="background" className="text-foreground" />
      
      <div className="w-full max-w-md space-y-8 text-center relative z-10">
        <div className="space-y-3">
          <h1 className="text-3xl font-medium">Imagen@rte</h1>
          <p className="text-muted-foreground">
            Tratamiento y protección de imágenes, sin nube.
          </p>
        </div>

        <div className="space-y-4 pt-4">
          <Button
            variant="primary"
            onClick={onStartImageFlow}
            className="w-full"
          >
            Tratar imagen
          </Button>

          {onDialDemo && (
            <Button
              variant="secondary"
              onClick={onDialDemo}
              className="w-full"
            >
              🎛️ Demo: Dial Buttons
            </Button>
          )}

          <Button
            variant="secondary"
            disabled
            className="w-full"
          >
            Tratar video (próximamente)
          </Button>
        </div>
      </div>
    </div>
  );
}
import { RadialMotif } from '@/app/components/RadialMotif';

interface StepperProps {
  currentStep: number;
  totalSteps: number;
}

export function Stepper({ currentStep, totalSteps }: StepperProps) {
  const progress = (currentStep / totalSteps) * 100;
  
  return (
    <div className="flex items-center justify-center gap-3 py-4">
      {/* Motivo radial de progreso */}
      <RadialMotif 
        variant="progress" 
        progress={progress}
        className="text-foreground flex-shrink-0"
      />
      
      <span className="text-sm text-muted-foreground">
        Paso {currentStep} de {totalSteps}
      </span>
    </div>
  );
}
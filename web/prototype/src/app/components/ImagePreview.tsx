import { cn } from '@/app/components/ui/utils';
import { RadialMotif } from '@/app/components/RadialMotif';

interface ImagePreviewProps {
  src: string | null;
  state: 'empty' | 'loading' | 'loaded' | 'error';
  className?: string;
}

export function ImagePreview({ src, state, className }: ImagePreviewProps) {
  return (
    <div className={cn(
      "w-full aspect-square rounded-lg border border-border overflow-hidden bg-muted flex items-center justify-center",
      className
    )}>
      {state === 'empty' && (
        <p className="text-sm text-muted-foreground">Sin imagen</p>
      )}
      
      {state === 'loading' && (
        <div className="flex flex-col items-center gap-2">
          <RadialMotif variant="loading" className="text-foreground" />
          <p className="text-sm text-muted-foreground">Cargando...</p>
        </div>
      )}
      
      {state === 'loaded' && src && (
        <img 
          src={src} 
          alt="Preview" 
          className="w-full h-full object-contain"
        />
      )}
      
      {state === 'error' && (
        <p className="text-sm text-destructive">Error al cargar imagen</p>
      )}
    </div>
  );
}
import { ReactNode } from 'react';
import { cn } from '@/app/components/ui/utils';

interface SectionCardProps {
  title?: string;
  children: ReactNode;
  className?: string;
}

export function SectionCard({ title, children, className }: SectionCardProps) {
  return (
    <div className={cn("bg-card border border-border rounded-xl p-4 space-y-4", className)}>
      {title && (
        <h3 className="text-sm font-medium">{title}</h3>
      )}
      <div className="space-y-4">
        {children}
      </div>
    </div>
  );
}

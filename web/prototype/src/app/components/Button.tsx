import { ButtonHTMLAttributes, forwardRef } from 'react';
import { cn } from '@/app/components/ui/utils';
import { RadialMotif } from '@/app/components/RadialMotif';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', isLoading, disabled, children, ...props }, ref) => {
    const baseStyles = "px-6 py-3 rounded-xl transition-all duration-150 disabled:opacity-50 disabled:cursor-not-allowed";
    
    const variantStyles = {
      primary: "bg-primary text-primary-foreground active:scale-[0.98] disabled:active:scale-100",
      secondary: "bg-secondary text-secondary-foreground active:scale-[0.98] disabled:active:scale-100 border border-border",
    };

    return (
      <button
        ref={ref}
        className={cn(baseStyles, variantStyles[variant], className)}
        disabled={disabled || isLoading}
        {...props}
      >
        {isLoading ? (
          <span className="flex items-center justify-center gap-2">
            <RadialMotif variant="loading" className="w-4 h-4" />
            {children}
          </span>
        ) : (
          children
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';
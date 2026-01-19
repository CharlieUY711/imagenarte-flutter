import { Switch } from '@/app/components/ui/switch';
import { cn } from '@/app/components/ui/utils';

interface ToggleProps {
  label: string;
  subtitle?: string;
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
  id?: string;
}

export function Toggle({ label, subtitle, checked, onCheckedChange, disabled, id }: ToggleProps) {
  return (
    <div className="flex items-start justify-between gap-4">
      <div className="flex-1">
        <label
          htmlFor={id}
          className={cn(
            "block cursor-pointer select-none",
            disabled && "opacity-50 cursor-not-allowed"
          )}
        >
          {label}
        </label>
        {subtitle && (
          <p className="text-sm text-muted-foreground mt-1">
            {subtitle}
          </p>
        )}
      </div>
      <Switch
        id={id}
        checked={checked}
        onCheckedChange={onCheckedChange}
        disabled={disabled}
      />
    </div>
  );
}

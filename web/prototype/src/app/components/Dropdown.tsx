import * as Select from '@radix-ui/react-select';
import { ChevronDown } from 'lucide-react';
import { cn } from '@/app/components/ui/utils';

interface DropdownOption {
  value: string;
  label: string;
}

interface DropdownProps {
  label: string;
  value: string;
  onValueChange: (value: string) => void;
  options: DropdownOption[];
  disabled?: boolean;
}

export function Dropdown({ label, value, onValueChange, options, disabled }: DropdownProps) {
  const selectedOption = options.find(opt => opt.value === value);
  
  return (
    <div className="space-y-2">
      <label className={cn("text-sm", disabled && "opacity-50")}>
        {label}
      </label>
      <Select.Root value={value} onValueChange={onValueChange} disabled={disabled}>
        <Select.Trigger
          className={cn(
            "flex w-full items-center justify-between rounded-lg border border-border bg-background px-4 py-3 text-sm transition-colors",
            "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
            "disabled:cursor-not-allowed disabled:opacity-50",
            "data-[placeholder]:text-muted-foreground"
          )}
        >
          <Select.Value>{selectedOption?.label}</Select.Value>
          <Select.Icon>
            <ChevronDown className="h-4 w-4" />
          </Select.Icon>
        </Select.Trigger>
        
        <Select.Portal>
          <Select.Content
            className="overflow-hidden bg-popover rounded-lg border border-border shadow-lg"
            position="popper"
            sideOffset={4}
          >
            <Select.Viewport className="p-1">
              {options.map((option) => (
                <Select.Item
                  key={option.value}
                  value={option.value}
                  className={cn(
                    "relative flex items-center px-4 py-2.5 text-sm rounded-md outline-none cursor-pointer select-none",
                    "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground",
                    "data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground"
                  )}
                >
                  <Select.ItemText>{option.label}</Select.ItemText>
                </Select.Item>
              ))}
            </Select.Viewport>
          </Select.Content>
        </Select.Portal>
      </Select.Root>
    </div>
  );
}

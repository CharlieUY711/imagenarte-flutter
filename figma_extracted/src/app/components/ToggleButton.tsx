import { useState } from 'react';

interface ToggleButtonProps {
  label: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
}

export function ToggleButton({ 
  label, 
  checked,
  onChange
}: ToggleButtonProps) {
  const [pressed, setPressed] = useState(false);

  const handleClick = () => {
    setPressed(true);
    setTimeout(() => setPressed(false), 100);
    onChange(!checked);
  };

  return (
    <button
      onClick={handleClick}
      className={`
        relative w-full px-3 rounded-sm transition-all duration-300
        h-[30px] flex items-center justify-center
        ${checked 
          ? 'border-2 border-orange-500 bg-[#1C1C1E]' 
          : 'border-[1px] border-border bg-[#1C1C1E] hover:bg-[#2C2C2E] active:bg-[#2C2C2E]'
        }
        ${pressed ? 'scale-[0.96]' : ''}
        select-none touch-none
      `}
    >
      <span className={`text-xs font-medium ${checked ? 'text-orange-500' : 'text-white'}`}>
        {label} {checked && '✓'}
      </span>
    </button>
  );
}

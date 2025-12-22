import React from 'react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'danger';
    children: React.ReactNode;
}

export function Button({ variant = 'primary', children, className = '', ...props }: ButtonProps) {
    const baseStyles = 'h-11 px-6 rounded-lg font-medium text-base transition-all duration-150 disabled:opacity-50 disabled:cursor-not-allowed';

    const variantStyles = {
        primary: 'bg-[#2563EB] text-white hover:bg-[#1D4ED8] hover:scale-[1.02] hover:shadow-md active:scale-[0.98]',
        secondary: 'bg-transparent border border-[#2563EB] text-[#2563EB] hover:bg-[#DBEAFE] active:scale-[0.98]',
        danger: 'bg-[#EF4444] text-white hover:bg-red-600 hover:scale-[1.02] hover:shadow-md active:scale-[0.98]'
    };

    return (
        <button
            className={`${baseStyles} ${variantStyles[variant]} ${className}`}
            {...props}
        >
            {children}
        </button>
    );
}

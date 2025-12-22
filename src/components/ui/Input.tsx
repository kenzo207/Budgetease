import React from 'react';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label?: string;
    error?: string;
}

export function Input({ label, error, className = '', ...props }: InputProps) {
    return (
        <div className="flex flex-col gap-1.5">
            {label && (
                <label className="text-sm font-medium text-gray-700">
                    {label}
                </label>
            )}
            <input
                className={`h-11 px-4 border border-gray-300 rounded-lg text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary-light transition-all ${error ? 'border-danger' : ''} ${className}`}
                {...props}
            />
            {error && (
                <span className="text-xs text-danger">{error}</span>
            )}
        </div>
    );
}

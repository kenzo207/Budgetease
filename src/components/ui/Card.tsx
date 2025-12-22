import React from 'react';

interface CardProps {
    children: React.ReactNode;
    className?: string;
    onClick?: () => void;
}

export function Card({ children, className = '', onClick }: CardProps) {
    const baseStyles = 'bg-white border border-gray-200 rounded-xl p-4 shadow-sm transition-shadow duration-200';
    const hoverStyles = onClick ? 'hover:shadow-md cursor-pointer' : '';

    return (
        <div className={`${baseStyles} ${hoverStyles} ${className}`} onClick={onClick}>
            {children}
        </div>
    );
}

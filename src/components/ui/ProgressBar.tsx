import React from 'react';

interface ProgressBarProps {
    value: number; // 0-100
    max?: number;
    status?: 'safe' | 'warning' | 'exceeded';
    showLabel?: boolean;
}

export function ProgressBar({ value, max = 100, status = 'safe', showLabel = true }: ProgressBarProps) {
    const percentage = Math.min((value / max) * 100, 100);

    const colorClasses = {
        safe: 'bg-primary',
        warning: 'bg-warning',
        exceeded: 'bg-danger'
    };

    return (
        <div className="w-full">
            <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                <div
                    className={`h-full ${colorClasses[status]} transition-all duration-300`}
                    style={{ width: `${percentage}%` }}
                />
            </div>
            {showLabel && (
                <div className="flex justify-between mt-1 text-xs text-gray-600">
                    <span>{Math.round(percentage)}%</span>
                </div>
            )}
        </div>
    );
}

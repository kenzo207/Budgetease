import React from 'react';

interface HeaderProps {
    title: string;
    action?: React.ReactNode;
}

export function Header({ title, action }: HeaderProps) {
    return (
        <header className="sticky top-0 bg-white border-b border-gray-200 z-10">
            <div className="flex items-center justify-between h-14 px-4">
                <div className="flex items-center gap-2">
                    <img src="/logo.png" alt="Logo" className="w-8 h-8 object-contain" />
                    <h1 className="text-xl font-semibold text-gray-900">{title}</h1>
                </div>
                {action && <div>{action}</div>}
            </div>
        </header>
    );
}

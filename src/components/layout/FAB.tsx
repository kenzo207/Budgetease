import React from 'react';
import { Plus } from 'lucide-react';

interface FABProps {
    onClick: () => void;
}

export function FAB({ onClick }: FABProps) {
    return (
        <button
            onClick={onClick}
            className="fixed bottom-20 right-6 w-14 h-14 bg-primary text-white rounded-full shadow-lg hover:scale-110 hover:rotate-90 active:scale-95 transition-all duration-200 flex items-center justify-center z-40"
            aria-label="Ajouter une transaction"
        >
            <Plus size={24} />
        </button>
    );
}

import React, { useState } from 'react';

interface RoundUpModalProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
    originalAmount: number;
    roundedAmount: number;
    currency: string;
}

export const RoundUpModal: React.FC<RoundUpModalProps> = ({
    isOpen,
    onClose,
    onConfirm,
    originalAmount,
    roundedAmount,
    currency
}) => {
    if (!isOpen) return null;

    const savings = roundedAmount - originalAmount;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white rounded-2xl w-full max-w-sm p-6 shadow-xl animate-in fade-in zoom-in duration-200">
                <div className="flex flex-col items-center text-center">
                    <div className="w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center mb-4">
                        <span className="text-2xl">🐷</span>
                    </div>

                    <h3 className="text-xl font-bold text-gray-900 mb-2">Arrondir pour épargner ?</h3>

                    <p className="text-gray-600 mb-6">
                        Notez une dépense de <span className="font-bold text-gray-900">{roundedAmount} {currency}</span>
                        <br />
                        et épargnez discrètement <span className="font-bold text-green-600">+{savings} {currency}</span>
                    </p>

                    <div className="flex gap-3 w-full">
                        <button
                            onClick={onClose}
                            className="flex-1 px-4 py-3 border border-gray-200 text-gray-700 font-medium rounded-xl hover:bg-gray-50 transition-colors"
                        >
                            Non, garder {originalAmount}
                        </button>
                        <button
                            onClick={onConfirm}
                            className="flex-1 px-4 py-3 bg-indigo-600 text-white font-bold rounded-xl hover:bg-indigo-700 transition-colors shadow-lg shadow-indigo-200"
                        >
                            Oui, arrondir
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

import React, { useState, useEffect } from 'react';

interface IceBlockModalProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
}

export const IceBlockModal: React.FC<IceBlockModalProps> = ({
    isOpen,
    onClose,
    onConfirm
}) => {
    const [secondsRemaining, setSecondsRemaining] = useState(10);

    useEffect(() => {
        if (!isOpen) {
            setSecondsRemaining(10);
            return;
        }

        const timer = setInterval(() => {
            setSecondsRemaining((prev) => {
                if (prev <= 1) {
                    clearInterval(timer);
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);

        return () => clearInterval(timer);
    }, [isOpen]);

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white rounded-2xl w-full max-w-sm p-6 shadow-xl border-t-4 border-blue-300 animate-in fade-in zoom-in duration-200">
                <div className="flex flex-col items-center text-center">
                    <div className="w-16 h-16 bg-blue-50 rounded-full flex items-center justify-center mb-4 animate-pulse">
                        <span className="text-3xl">❄️</span>
                    </div>

                    <h3 className="text-xl font-bold text-gray-900 mb-2">Pause Fraîcheur</h3>

                    <p className="text-gray-600 mb-6 text-sm">
                        Cette dépense n'est pas essentielle et votre score de risque est élevé.
                        <br /><br />
                        <span className="font-medium text-gray-900">En avez-vous vraiment besoin maintenant ?</span>
                    </p>

                    <div className="w-full flex flex-col gap-3">
                        <button
                            onClick={onConfirm}
                            disabled={secondsRemaining > 0}
                            className={`w-full py-3 rounded-xl font-bold transition-all ${secondsRemaining > 0
                                    ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                    : 'bg-blue-600 text-white hover:bg-blue-700 shadow-lg shadow-blue-200'
                                }`}
                        >
                            {secondsRemaining > 0
                                ? `Attendez ${secondsRemaining}s...`
                                : 'Oui, je confirme'}
                        </button>

                        <button
                            onClick={onClose}
                            className="w-full py-2 text-gray-500 font-medium hover:text-gray-700"
                        >
                            Non, j'annule
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

import React, { useState, useEffect } from 'react';
import { Button } from '../components/ui/Button';
import { Select } from '../components/ui/Select';
import { Currency, Category } from '../types';
import { db } from '../lib/db';

interface OnboardingProps {
    onComplete: () => void;
}

export function Onboarding({ onComplete }: OnboardingProps) {
    const [step, setStep] = useState(1);
    const [currency, setCurrency] = useState<Currency>('FCFA');
    const [notificationTime, setNotificationTime] = useState('20:00');
    const [enableNotifications, setEnableNotifications] = useState(false);
    const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);

    useEffect(() => {
        loadCategories();
    }, []);

    const loadCategories = async () => {
        const cats = await db.categories.toArray();
        setCategories(cats);
    };

    const toggleCategory = (categoryName: string) => {
        if (selectedCategories.includes(categoryName)) {
            setSelectedCategories(selectedCategories.filter(c => c !== categoryName));
        } else if (selectedCategories.length < 3) {
            setSelectedCategories([...selectedCategories, categoryName]);
        }
    };

    const handleComplete = async () => {
        const settings = await db.settings.toArray();
        if (settings.length > 0) {
            await db.settings.update(settings[0].id!, {
                currency,
                notificationEnabled: enableNotifications,
                notificationTime,
                onboardingCompleted: true,
                favoriteCategories: selectedCategories
            });
        }
        onComplete();
    };

    const currencyOptions = [
        { value: 'FCFA', label: 'FCFA (Franc CFA)' },
        { value: 'NGN', label: 'NGN (Naira)' },
        { value: 'GHS', label: 'GHS (Cedi)' },
        { value: 'USD', label: 'USD (Dollar)' },
        { value: 'EUR', label: 'EUR (Euro)' }
    ];

    return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
            <div className="w-full max-w-md bg-white rounded-2xl shadow-lg p-6 space-y-6">
                {/* Header */}
                <div className="text-center">
                    <div className="flex justify-center mb-4">
                        <img src="/logo.png" alt="Logo" className="w-20 h-20 object-contain" />
                    </div>
                    <h1 className="text-2xl font-bold text-gray-900">BudgetEase</h1>
                    <p className="text-sm text-gray-600 mt-2">
                        Gérez votre budget simplement
                    </p>
                </div>

                {/* Progress */}
                <div className="flex gap-2">
                    {[1, 2, 3].map(i => (
                        <div
                            key={i}
                            className={`h-1.5 flex-1 rounded-full transition-colors ${i <= step ? 'bg-primary' : 'bg-gray-200'
                                }`}
                        />
                    ))}
                </div>

                {/* Step 1: Currency */}
                {step === 1 && (
                    <div className="space-y-4">
                        <div>
                            <h2 className="text-lg font-semibold text-gray-900 mb-2">
                                Sélectionnez votre devise
                            </h2>
                            <p className="text-sm text-gray-600">
                                Vous pourrez la modifier plus tard dans les paramètres
                            </p>
                        </div>

                        <Select
                            value={currency}
                            onChange={(e) => setCurrency(e.target.value as Currency)}
                            options={currencyOptions}
                        />

                        <Button onClick={() => setStep(2)} className="w-full">
                            Continuer
                        </Button>
                    </div>
                )}

                {/* Step 2: Notifications */}
                {step === 2 && (
                    <div className="space-y-4">
                        <div>
                            <h2 className="text-lg font-semibold text-gray-900 mb-2">
                                Rappel quotidien
                            </h2>
                            <p className="text-sm text-gray-600">
                                Recevez un rappel pour enregistrer vos dépenses (optionnel)
                            </p>
                        </div>

                        <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                            <span className="text-sm font-medium text-gray-700">Activer le rappel</span>
                            <button
                                onClick={() => setEnableNotifications(!enableNotifications)}
                                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${enableNotifications ? 'bg-primary' : 'bg-gray-300'
                                    }`}
                            >
                                <span
                                    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${enableNotifications ? 'translate-x-6' : 'translate-x-1'
                                        }`}
                                />
                            </button>
                        </div>

                        {enableNotifications && (
                            <div>
                                <label className="text-sm font-medium text-gray-700 block mb-1.5">
                                    Heure du rappel
                                </label>
                                <input
                                    type="time"
                                    value={notificationTime}
                                    onChange={(e) => setNotificationTime(e.target.value)}
                                    className="w-full h-11 px-4 border border-gray-300 rounded-lg text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary-light transition-all"
                                />
                            </div>
                        )}

                        <div className="flex gap-3">
                            <Button variant="secondary" onClick={() => setStep(1)} className="flex-1">
                                Retour
                            </Button>
                            <Button onClick={() => setStep(3)} className="flex-1">
                                Continuer
                            </Button>
                        </div>
                    </div>
                )}

                {/* Step 3: Favorite Categories */}
                {step === 3 && (
                    <div className="space-y-4">
                        <div>
                            <h2 className="text-lg font-semibold text-gray-900 mb-2">
                                Catégories favorites
                            </h2>
                            <p className="text-sm text-gray-600">
                                Sélectionnez 3 catégories que vous utilisez le plus
                            </p>
                        </div>

                        <div className="grid grid-cols-2 gap-2">
                            {categories.filter(c => c.isDefault).map(category => (
                                <button
                                    key={category.id}
                                    onClick={() => toggleCategory(category.name)}
                                    className={`p-3 rounded-lg border-2 transition-all ${selectedCategories.includes(category.name)
                                        ? 'border-primary bg-primary-light'
                                        : 'border-gray-200 hover:border-gray-300'
                                        }`}
                                >
                                    <div className="text-2xl mb-1">{category.icon}</div>
                                    <div className="text-sm font-medium text-gray-900">{category.name}</div>
                                </button>
                            ))}
                        </div>

                        <p className="text-xs text-gray-500 text-center">
                            {selectedCategories.length}/3 sélectionnées
                        </p>

                        <div className="flex gap-3">
                            <Button variant="secondary" onClick={() => setStep(2)} className="flex-1">
                                Retour
                            </Button>
                            <Button
                                onClick={handleComplete}
                                className="flex-1"
                                disabled={selectedCategories.length === 0}
                            >
                                Commencer
                            </Button>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}

import React, { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { Button } from '../ui/Button';
import { FixedCharge } from '../../types';

interface FixedChargeFormProps {
    isOpen: boolean;
    onClose: () => void;
    onSave: (data: Omit<FixedCharge, 'id'>) => Promise<void>;
    initialData?: FixedCharge;
}

export function FixedChargeForm({ isOpen, onClose, onSave, initialData }: FixedChargeFormProps) {
    const { register, handleSubmit, reset, setValue } = useForm<FixedCharge>();

    useEffect(() => {
        if (isOpen && initialData) {
            setValue('title', initialData.title);
            setValue('amount', initialData.amount);
            setValue('frequency', initialData.frequency);
            setValue('nextDueDate', new Date(initialData.nextDueDate).toISOString().split('T')[0] as any);
            setValue('isActive', initialData.isActive);
        } else if (isOpen) {
            reset({
                frequency: 'monthly',
                isActive: true,
                nextDueDate: new Date()
            });
        }
    }, [isOpen, initialData, setValue, reset]);

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-200">
            <div className="w-full max-w-lg bg-white rounded-t-2xl sm:rounded-2xl shadow-xl overflow-hidden animate-in slide-in-from-bottom duration-300">
                <div className="p-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                    <h2 className="text-lg font-semibold text-gray-900">
                        {initialData ? 'Modifier la charge' : 'Nouvelle charge fixe'}
                    </h2>
                    <button onClick={onClose} className="p-2 -mr-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100">
                        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <form onSubmit={handleSubmit((data: FixedCharge) => {
                    onSave({
                        ...data,
                        amount: Number(data.amount),
                        nextDueDate: new Date(data.nextDueDate)
                    });
                    onClose();
                })} className="p-6 space-y-6">

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Nom</label>
                            <input
                                {...register('title', { required: true })}
                                type="text"
                                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all"
                                placeholder="Ex: Loyer, Netflix..."
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1.5">Montant</label>
                                <div className="relative">
                                    <input
                                        {...register('amount', { required: true, min: 0 })}
                                        type="number"
                                        className="w-full pl-4 pr-12 py-3 rounded-xl border border-gray-200 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all"
                                        placeholder="0"
                                    />
                                    <span className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 font-medium">FCFA</span>
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1.5">Fréquence</label>
                                <select
                                    {...register('frequency')}
                                    className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all bg-white"
                                >
                                    <option value="daily">Quotidien</option>
                                    <option value="weekly">Hebdomadaire</option>
                                    <option value="monthly">Mensuel</option>
                                    <option value="yearly">Annuel</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Prochaine échéance</label>
                            <input
                                {...register('nextDueDate', { required: true })}
                                type="date"
                                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all"
                            />
                        </div>
                    </div>

                    <div className="pt-2 flex gap-3">
                        <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
                            Annuler
                        </Button>
                        <Button type="submit" className="flex-1">
                            Enregistrer
                        </Button>
                    </div>
                </form>
            </div>
        </div>
    );
}

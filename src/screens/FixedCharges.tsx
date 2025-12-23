import React, { useState, useEffect } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../lib/db';
import { FixedCharge } from '../types';
import { Header } from '../components/layout/Header';
import { FixedChargeForm } from '../components/fixed_charges/FixedChargeForm';
import { getMonthlyFixedCharges } from '../lib/calculations';
import { formatCurrency } from '../utils/formatters';

export function FixedCharges() {
    const charges = useLiveQuery(() => db.fixedCharges.toArray());
    const settings = useLiveQuery(() => db.settings.toArray());
    const currency = settings?.[0]?.currency || 'FCFA';

    const [isFormOpen, setIsFormOpen] = useState(false);
    const [editingCharge, setEditingCharge] = useState<FixedCharge | undefined>();

    const totalMonthly = charges ? getMonthlyFixedCharges(charges) : 0;

    const handleSave = async (data: Omit<FixedCharge, 'id'>) => {
        if (editingCharge?.id) {
            await db.fixedCharges.update(editingCharge.id, data);
        } else {
            await db.fixedCharges.add(data as FixedCharge);
        }
        setEditingCharge(undefined);
    };

    const handleDelete = async (id: number) => {
        if (confirm('Voulez-vous vraiment supprimer cette charge ?')) {
            await db.fixedCharges.delete(id);
        }
    };

    const handleToggleActive = async (charge: FixedCharge) => {
        await db.fixedCharges.update(charge.id!, { isActive: !charge.isActive });
    };

    return (
        <div className="bg-gray-50 min-h-screen pb-20">
            <Header
                title="Charges Fixes"
                action={
                    <button
                        onClick={() => setIsFormOpen(true)}
                        className="p-2 text-primary hover:bg-primary/10 rounded-full transition-colors"
                    >
                        <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                        </svg>
                    </button>
                }
            />

            <div className="p-4 space-y-6">
                {/* KPI Card */}
                <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 flex items-center gap-4">
                    <div className="p-3 bg-primary/10 rounded-xl text-primary">
                        <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-500">Total mensuel bloqué</p>
                        <p className="text-2xl font-bold text-gray-900">
                            {formatCurrency(totalMonthly, currency)}
                        </p>
                    </div>
                </div>

                {/* List */}
                <div className="space-y-3">
                    {charges?.map((charge: FixedCharge) => (
                        <div
                            key={charge.id}
                            className={`bg-white rounded-xl p-4 shadow-sm border border-gray-100 transition-opacity ${!charge.isActive ? 'opacity-60' : ''}`}
                        >
                            <div className="flex justify-between items-start mb-2">
                                <div className="flex items-center gap-3">
                                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${charge.isActive ? 'bg-gray-100 text-gray-600' : 'bg-gray-50 text-gray-400'}`}>
                                        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                    </div>
                                    <div>
                                        <h3 className={`font-semibold ${charge.isActive ? 'text-gray-900' : 'text-gray-500 line-through'}`}>
                                            {charge.title}
                                        </h3>
                                        <p className="text-xs text-gray-500 capitalize">
                                            {charge.frequency === 'daily' && 'Chaque jour'}
                                            {charge.frequency === 'weekly' && 'Chaque semaine'}
                                            {charge.frequency === 'monthly' && 'Chaque mois'}
                                            {charge.frequency === 'yearly' && 'Chaque année'}
                                        </p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2">
                                    <span className={`font-bold ${charge.isActive ? 'text-gray-900' : 'text-gray-400'}`}>
                                        {formatCurrency(charge.amount, currency)}
                                    </span>
                                </div>
                            </div>

                            <div className="flex justify-end gap-2 mt-4 pt-3 border-t border-gray-50">
                                <button
                                    onClick={() => handleToggleActive(charge)}
                                    className={`text-xs font-medium px-3 py-1.5 rounded-lg transition-colors ${charge.isActive
                                        ? 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                                        : 'bg-green-50 text-green-600 hover:bg-green-100'
                                        }`}
                                >
                                    {charge.isActive ? 'Désactiver' : 'Activer'}
                                </button>
                                <button
                                    onClick={() => {
                                        setEditingCharge(charge);
                                        setIsFormOpen(true);
                                    }}
                                    className="text-xs font-medium px-3 py-1.5 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors"
                                >
                                    Modifier
                                </button>
                                <button
                                    onClick={() => handleDelete(charge.id!)}
                                    className="text-xs font-medium px-3 py-1.5 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-colors"
                                >
                                    Supprimer
                                </button>
                            </div>
                        </div>
                    ))}

                    {charges?.length === 0 && (
                        <div className="text-center py-12">
                            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4 text-gray-400">
                                <svg className="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                                </svg>
                            </div>
                            <h3 className="text-lg font-medium text-gray-900 mb-1">Aucune charge fixe</h3>
                            <p className="text-sm text-gray-500 max-w-xs mx-auto">
                                Ajoutez vos loyers, abonnements et factures récurrentes pour mieux gérer votre budget.
                            </p>
                        </div>
                    )}
                </div>
            </div>

            <FixedChargeForm
                isOpen={isFormOpen}
                onClose={() => {
                    setIsFormOpen(false);
                    setEditingCharge(undefined);
                }}
                onSave={handleSave}
                initialData={editingCharge}
            />
        </div>
    );
}

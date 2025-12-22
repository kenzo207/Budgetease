import React, { useState, useEffect } from 'react';
import { Header } from '../components/layout/Header';
import { BudgetCard } from '../components/budgets/BudgetCard';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { BudgetProgress, Currency, Category } from '../types';
import { getAllBudgetsProgress } from '../lib/calculations';
import { db } from '../lib/db';
import { Plus } from 'lucide-react';

export function Budgets() {
    const [budgets, setBudgets] = useState<BudgetProgress[]>([]);
    const [currency, setCurrency] = useState<Currency>('FCFA');
    const [categories, setCategories] = useState<Category[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [formCategory, setFormCategory] = useState('');
    const [formAmount, setFormAmount] = useState('');
    const [formError, setFormError] = useState('');

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const [budgetProgress, settings, cats] = await Promise.all([
                getAllBudgetsProgress(),
                db.settings.toArray(),
                db.categories.toArray()
            ]);

            setBudgets(budgetProgress);
            setCategories(cats);

            if (settings.length > 0) {
                setCurrency(settings[0].currency);
            }
        } catch (error) {
            console.error('Error loading budgets:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setFormError('');

        const amount = parseFloat(formAmount);
        if (isNaN(amount) || amount <= 0) {
            setFormError('Le montant doit être supérieur à 0');
            return;
        }

        if (!formCategory) {
            setFormError('Veuillez sélectionner une catégorie');
            return;
        }

        try {
            const currentMonth = new Date().toISOString().slice(0, 7);

            // Check if budget already exists
            const existing = await db.budgets
                .where('category')
                .equals(formCategory)
                .and(b => b.month === currentMonth)
                .first();

            if (existing) {
                await db.budgets.update(existing.id!, { amount });
            } else {
                await db.budgets.add({
                    category: formCategory,
                    amount,
                    month: currentMonth,
                    createdAt: new Date()
                });
            }

            setShowForm(false);
            setFormCategory('');
            setFormAmount('');
            loadData();
        } catch (error) {
            setFormError('Une erreur est survenue');
            console.error(error);
        }
    };

    const categoryOptions = categories.map(c => ({
        value: c.name,
        label: `${c.icon} ${c.name}`
    }));

    return (
        <div className="pb-20">
            <Header
                title="Budgets mensuels"
                action={
                    <button
                        onClick={() => setShowForm(true)}
                        className="text-primary font-medium text-sm flex items-center gap-1"
                    >
                        <Plus size={18} />
                        Créer
                    </button>
                }
            />

            <div className="p-4 space-y-3">
                {loading ? (
                    <div className="text-center py-12 text-gray-500">
                        Chargement...
                    </div>
                ) : budgets.length === 0 ? (
                    <div className="text-center py-12">
                        <p className="text-gray-500 mb-4">Aucun budget défini</p>
                        <Button onClick={() => setShowForm(true)}>
                            Créer un budget
                        </Button>
                    </div>
                ) : (
                    budgets.map((budget, index) => (
                        <BudgetCard
                            key={index}
                            budget={budget}
                            currency={currency}
                        />
                    ))
                )}
            </div>

            {/* Budget Form Modal */}
            <Modal
                isOpen={showForm}
                onClose={() => {
                    setShowForm(false);
                    setFormError('');
                }}
                title="Nouveau budget"
            >
                <form onSubmit={handleSubmit} className="space-y-4">
                    <Select
                        label="Catégorie"
                        value={formCategory}
                        onChange={(e) => setFormCategory(e.target.value)}
                        options={[
                            { value: '', label: 'Sélectionner une catégorie' },
                            ...categoryOptions
                        ]}
                        required
                    />

                    <Input
                        label="Montant mensuel"
                        type="number"
                        step="0.01"
                        value={formAmount}
                        onChange={(e) => setFormAmount(e.target.value)}
                        placeholder="0"
                        required
                    />

                    {formError && (
                        <div className="p-3 bg-danger-light text-danger rounded-lg text-sm">
                            {formError}
                        </div>
                    )}

                    <div className="flex gap-3 pt-2">
                        <Button
                            type="button"
                            variant="secondary"
                            onClick={() => setShowForm(false)}
                            className="flex-1"
                        >
                            Annuler
                        </Button>
                        <Button type="submit" variant="primary" className="flex-1">
                            Enregistrer
                        </Button>
                    </div>
                </form>
            </Modal>
        </div>
    );
}

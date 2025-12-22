import React, { useState } from 'react';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { Select } from '../ui/Select';
import { Transaction, TransactionType, PaymentMethod, Category } from '../../types';
import { db } from '../../lib/db';

interface TransactionFormProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    transaction?: Transaction;
    categories: Category[];
}

export function TransactionForm({ isOpen, onClose, onSuccess, transaction, categories }: TransactionFormProps) {
    const [type, setType] = useState<TransactionType>(transaction?.type || 'expense');
    const [amount, setAmount] = useState(transaction?.amount.toString() || '');
    const [category, setCategory] = useState(transaction?.category || '');
    const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>(transaction?.paymentMethod || 'MoMo');
    const [date, setDate] = useState(
        transaction?.date
            ? new Date(transaction.date).toISOString().split('T')[0]
            : new Date().toISOString().split('T')[0]
    );
    const [note, setNote] = useState(transaction?.note || '');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');

        const amountNum = parseFloat(amount);
        if (isNaN(amountNum) || amountNum <= 0) {
            setError('Le montant doit être supérieur à 0');
            return;
        }

        if (!category) {
            setError('Veuillez sélectionner une catégorie');
            return;
        }

        setLoading(true);

        try {
            const transactionData: Transaction = {
                type,
                amount: amountNum,
                category,
                paymentMethod,
                date: new Date(date),
                note: note.trim() || undefined,
                createdAt: transaction?.createdAt || new Date()
            };

            if (transaction?.id) {
                await db.transactions.update(transaction.id, transactionData);
            } else {
                await db.transactions.add(transactionData);
            }

            onSuccess();
            onClose();
            resetForm();
        } catch (err) {
            setError('Une erreur est survenue');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const resetForm = () => {
        setType('expense');
        setAmount('');
        setCategory('');
        setPaymentMethod('MoMo');
        setDate(new Date().toISOString().split('T')[0]);
        setNote('');
        setError('');
    };

    const categoryOptions = categories.map(c => ({
        value: c.name,
        label: `${c.icon} ${c.name}`
    }));

    return (
        <Modal isOpen={isOpen} onClose={onClose} title={transaction ? 'Modifier' : 'Nouvelle transaction'}>
            <form onSubmit={handleSubmit} className="space-y-4">
                {/* Type */}
                <div className="flex gap-2">
                    <button
                        type="button"
                        onClick={() => setType('expense')}
                        className={`flex-1 py-2.5 rounded-lg font-medium transition-colors ${type === 'expense'
                                ? 'bg-primary text-white'
                                : 'bg-gray-100 text-gray-700'
                            }`}
                    >
                        Dépense
                    </button>
                    <button
                        type="button"
                        onClick={() => setType('income')}
                        className={`flex-1 py-2.5 rounded-lg font-medium transition-colors ${type === 'income'
                                ? 'bg-success text-white'
                                : 'bg-gray-100 text-gray-700'
                            }`}
                    >
                        Revenu
                    </button>
                </div>

                {/* Amount */}
                <Input
                    label="Montant"
                    type="number"
                    step="0.01"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder="0"
                    required
                />

                {/* Category */}
                <Select
                    label="Catégorie"
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    options={[
                        { value: '', label: 'Sélectionner une catégorie' },
                        ...categoryOptions
                    ]}
                    required
                />

                {/* Payment Method */}
                <div>
                    <label className="text-sm font-medium text-gray-700 block mb-2">
                        Moyen de paiement
                    </label>
                    <div className="flex gap-2">
                        {(['MoMo', 'Cash', 'Carte'] as PaymentMethod[]).map(method => (
                            <button
                                key={method}
                                type="button"
                                onClick={() => setPaymentMethod(method)}
                                className={`flex-1 py-2.5 rounded-lg font-medium transition-colors ${paymentMethod === method
                                        ? 'bg-primary text-white'
                                        : 'bg-gray-100 text-gray-700'
                                    }`}
                            >
                                {method}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Date */}
                <Input
                    label="Date"
                    type="date"
                    value={date}
                    onChange={(e) => setDate(e.target.value)}
                    required
                />

                {/* Note */}
                <div>
                    <label className="text-sm font-medium text-gray-700 block mb-1.5">
                        Note (optionnelle)
                    </label>
                    <textarea
                        value={note}
                        onChange={(e) => setNote(e.target.value)}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary-light transition-all resize-none"
                        rows={3}
                        placeholder="Ajouter une note..."
                    />
                </div>

                {error && (
                    <div className="p-3 bg-danger-light text-danger rounded-lg text-sm">
                        {error}
                    </div>
                )}

                {/* Actions */}
                <div className="flex gap-3 pt-2">
                    <Button
                        type="button"
                        variant="secondary"
                        onClick={onClose}
                        className="flex-1"
                        disabled={loading}
                    >
                        Annuler
                    </Button>
                    <Button
                        type="submit"
                        variant="primary"
                        className="flex-1"
                        disabled={loading}
                    >
                        {loading ? 'Enregistrement...' : 'Enregistrer'}
                    </Button>
                </div>
            </form>
        </Modal>
    );
}

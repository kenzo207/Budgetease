import React, { useState } from 'react';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { Select } from '../ui/Select';
import { Transaction, TransactionType, PaymentMethod, Category } from '../../types';
import { db } from '../../lib/db';
import { RoundUpModal } from '../ui/RoundUpModal';
import { IceBlockModal } from '../ui/IceBlockModal';
import { getOrCreateBehavioralProfile, getRiskScore, isEveningSpender } from '../../lib/behavioral-profiler';

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

    // Behavioral State
    const [showRoundUp, setShowRoundUp] = useState(false);
    const [roundUpData, setRoundUpData] = useState({ original: 0, rounded: 0 });
    const [showIceBlock, setShowIceBlock] = useState(false);
    const [pendingTransaction, setPendingTransaction] = useState<Transaction | null>(null);

    const checkGamification = (amountVal: number): boolean => {
        if (type !== 'expense') return false;

        // Simple Round Up Logic (same as Flutter)
        const amountInt = Math.floor(amountVal);
        let nextTier = 0;

        if (amountInt < 1000) nextTier = Math.ceil(amountInt / 100) * 100;
        else nextTier = Math.ceil(amountInt / 1000) * 1000;

        if (nextTier === amountInt) nextTier += (amountInt < 1000 ? 100 : 1000);

        const diff = nextTier - amountInt;

        // Conditions: diff is small enough (< 20% of amount, max 500)
        if (diff > 0 && diff <= 500 && (diff / amountInt) < 0.2) {
            setRoundUpData({ original: amountVal, rounded: nextTier });
            return true;
        }
        return false;
    };

    const checkFriction = async (currentCategory: string): Promise<boolean> => {
        if (type !== 'expense') return false;

        const essentialCategories = ['Logement', 'Santé', 'Éducation', 'Alimentation', 'Transport'];
        if (essentialCategories.includes(currentCategory)) return false;

        try {
            const profile = await getOrCreateBehavioralProfile();
            const riskScore = getRiskScore(profile);

            // Trigger if Risk > 0.7 OR (Risk > 0.5 AND Evening Spender)
            if (riskScore > 0.7 || (riskScore > 0.5 && isEveningSpender(profile))) {
                return true;
            }
        } catch (e) {
            console.error(e);
        }
        return false;
    };

    const processSave = async (finalAmount: number, shadowSavings: number = 0) => {
        setLoading(true);
        try {
            const transactionData: Transaction = {
                type,
                amount: finalAmount,
                category,
                paymentMethod,
                date: new Date(date),
                note: note.trim() || undefined,
                createdAt: transaction?.createdAt || new Date(),
                shadowSavings
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

        // Interceptor 1: Gamification
        if (checkGamification(amountNum)) {
            setShowRoundUp(true);
            return;
        }

        // Interceptor 2: Friction
        if (await checkFriction(category)) {
            setShowIceBlock(true);
            return;
        }

        // Proceed
        await processSave(amountNum);
    };

    const handleRoundUpConfirm = async () => {
        setShowRoundUp(false);
        const { original, rounded } = roundUpData;

        // Still check friction after round up
        if (await checkFriction(category)) {
            // Store pending data to use after friction
            setPendingTransaction({
                type, amount: rounded, category, paymentMethod, date: new Date(date), createdAt: new Date(),
                shadowSavings: rounded - original
            });
            setShowIceBlock(true);
        } else {
            await processSave(rounded, rounded - original);
        }
    };

    const handleRoundUpDecline = async () => {
        setShowRoundUp(false);
        const amountNum = parseFloat(amount);

        if (await checkFriction(category)) {
            setPendingTransaction({
                type, amount: amountNum, category, paymentMethod, date: new Date(date), createdAt: new Date(),
                shadowSavings: 0
            });
            setShowIceBlock(true);
        } else {
            await processSave(amountNum);
        }
    };

    const handleIceBlockConfirm = async () => {
        setShowIceBlock(false);
        if (pendingTransaction) {
            await processSave(pendingTransaction.amount, pendingTransaction.shadowSavings);
        } else {
            await processSave(parseFloat(amount), 0);
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
        setShowRoundUp(false);
        setShowIceBlock(false);
        setPendingTransaction(null);
    };

    const categoryOptions = categories.map(c => ({
        value: c.name,
        label: `${c.icon} ${c.name}`
    }));

    return (
        <>
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

            <RoundUpModal
                isOpen={showRoundUp}
                onClose={handleRoundUpDecline}
                onConfirm={handleRoundUpConfirm}
                originalAmount={roundUpData.original}
                roundedAmount={roundUpData.rounded}
                currency="FCFA"
            />

            <IceBlockModal
                isOpen={showIceBlock}
                onClose={() => setShowIceBlock(false)}
                onConfirm={handleIceBlockConfirm}
            />
        </>
    );
}

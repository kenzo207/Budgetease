import React, { useState, useEffect } from 'react';
import { Header } from '../components/layout/Header';
import { TransactionItem } from '../components/transactions/TransactionItem';
import { Select } from '../components/ui/Select';
import { Transaction, Currency, Category } from '../types';
import { db } from '../lib/db';
import { format, startOfMonth, endOfMonth, startOfWeek, endOfWeek, startOfDay } from 'date-fns';
import { fr } from 'date-fns/locale';
import { Search } from 'lucide-react';

interface HistoryProps {
    onEditTransaction: (transaction: Transaction) => void;
}

export function History({ onEditTransaction }: HistoryProps) {
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [filteredTransactions, setFilteredTransactions] = useState<Transaction[]>([]);
    const [currency, setCurrency] = useState<Currency>('FCFA');
    const [period, setPeriod] = useState('month');
    const [categoryFilter, setCategoryFilter] = useState('all');
    const [categories, setCategories] = useState<Category[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadData();
    }, []);

    useEffect(() => {
        filterTransactions();
    }, [transactions, period, categoryFilter]);

    const loadData = async () => {
        setLoading(true);
        try {
            const [allTransactions, settings, cats] = await Promise.all([
                db.transactions.orderBy('date').reverse().toArray(),
                db.settings.toArray(),
                db.categories.toArray()
            ]);

            setTransactions(allTransactions);
            setCategories(cats);

            if (settings.length > 0) {
                setCurrency(settings[0].currency);
            }
        } catch (error) {
            console.error('Error loading history:', error);
        } finally {
            setLoading(false);
        }
    };

    const filterTransactions = () => {
        let filtered = [...transactions];

        // Filter by period
        const now = new Date();
        let startDate: Date;

        switch (period) {
            case 'day':
                startDate = startOfDay(now);
                break;
            case 'week':
                startDate = startOfWeek(now, { weekStartsOn: 1 });
                break;
            case 'month':
                startDate = startOfMonth(now);
                break;
            default:
                startDate = new Date(0); // All time
        }

        filtered = filtered.filter(t => new Date(t.date) >= startDate);

        // Filter by category
        if (categoryFilter !== 'all') {
            filtered = filtered.filter(t => t.category === categoryFilter);
        }

        setFilteredTransactions(filtered);
    };

    const handleDelete = async (id: number) => {
        await db.transactions.delete(id);
        loadData();
    };

    const groupedTransactions = groupByDate(filteredTransactions);

    const periodOptions = [
        { value: 'all', label: 'Tout' },
        { value: 'day', label: 'Aujourd\'hui' },
        { value: 'week', label: 'Cette semaine' },
        { value: 'month', label: 'Ce mois-ci' }
    ];

    const categoryOptions = [
        { value: 'all', label: 'Toutes les catégories' },
        ...categories.map(c => ({ value: c.name, label: c.name }))
    ];

    return (
        <div className="pb-20">
            <Header title="Historique" />

            <div className="p-4 space-y-4">
                {/* Filters */}
                <div className="grid grid-cols-2 gap-3">
                    <Select
                        value={period}
                        onChange={(e) => setPeriod(e.target.value)}
                        options={periodOptions}
                        className="text-sm"
                    />
                    <Select
                        value={categoryFilter}
                        onChange={(e) => setCategoryFilter(e.target.value)}
                        options={categoryOptions}
                        className="text-sm"
                    />
                </div>

                {/* Transactions */}
                {loading ? (
                    <div className="text-center py-12 text-gray-500">
                        Chargement...
                    </div>
                ) : filteredTransactions.length === 0 ? (
                    <div className="text-center py-12">
                        <p className="text-gray-500">Aucune transaction pour cette période</p>
                    </div>
                ) : (
                    <div className="space-y-6">
                        {Object.entries(groupedTransactions).map(([date, txs]) => (
                            <div key={date}>
                                <h3 className="text-sm font-semibold text-gray-600 mb-2 px-1">
                                    {date}
                                </h3>
                                <div className="space-y-2">
                                    {txs.map(transaction => (
                                        <TransactionItem
                                            key={transaction.id}
                                            transaction={transaction}
                                            currency={currency}
                                            onEdit={onEditTransaction}
                                            onDelete={handleDelete}
                                        />
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}

function groupByDate(transactions: Transaction[]): Record<string, Transaction[]> {
    const grouped: Record<string, Transaction[]> = {};
    const now = new Date();

    transactions.forEach(t => {
        const date = new Date(t.date);
        let label: string;

        if (format(date, 'yyyy-MM-dd') === format(now, 'yyyy-MM-dd')) {
            label = 'Aujourd\'hui';
        } else if (format(date, 'yyyy-MM-dd') === format(new Date(now.getTime() - 86400000), 'yyyy-MM-dd')) {
            label = 'Hier';
        } else {
            label = format(date, 'EEEE d MMMM', { locale: fr });
        }

        if (!grouped[label]) {
            grouped[label] = [];
        }
        grouped[label].push(t);
    });

    return grouped;
}

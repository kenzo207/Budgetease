import React, { useState, useEffect } from 'react';
import { Header } from '../components/layout/Header';
import { SummaryCard } from '../components/dashboard/SummaryCard';
import { TopCategories } from '../components/dashboard/TopCategories';
import { CategoryPieChart } from '../components/dashboard/CategoryPieChart';
import { Select } from '../components/ui/Select';
import { Period, PeriodTotals, CategoryTotal, Currency } from '../types';
import { getPeriodTotals, getTopCategories, getCategoryBreakdown } from '../lib/calculations';
import { db } from '../lib/db';

export function Dashboard() {
    const [period, setPeriod] = useState<Period>('month');
    const [totals, setTotals] = useState<PeriodTotals>({ income: 0, expenses: 0, balance: 0 });
    const [topCategories, setTopCategories] = useState<CategoryTotal[]>([]);
    const [allCategories, setAllCategories] = useState<CategoryTotal[]>([]);
    const [currency, setCurrency] = useState<Currency>('FCFA');
    const [sosAmount, setSosAmount] = useState<number>(0);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadData();
    }, [period]);

    useEffect(() => {
        loadSettings();
    }, []);

    const loadSettings = async () => {
        const settings = await db.settings.toArray();
        if (settings.length > 0) {
            setCurrency(settings[0].currency);
            setSosAmount(settings[0].sosAmount || 0);
        }
    };

    const toggleSOS = async () => {
        const settings = await db.settings.toArray();
        if (settings.length === 0) return;
        const settingId = settings[0].id!;

        if (sosAmount > 0) {
            if (window.confirm("Désactiver le mode SOS ?")) {
                await db.settings.update(settingId, { sosAmount: 0 });
                setSosAmount(0);
            }
        } else {
            const amountStr = window.prompt("Mode SOS 🚨\nEntrez le montant à réserver pour l'urgence :", "10000");
            if (amountStr) {
                const amount = parseFloat(amountStr);
                if (!isNaN(amount) && amount > 0) {
                    await db.settings.update(settingId, { sosAmount: amount });
                    setSosAmount(amount);
                }
            }
        }
    };

    const loadData = async () => {
        setLoading(true);
        try {
            const [periodTotals, top, all] = await Promise.all([
                getPeriodTotals(period),
                getTopCategories(3, period),
                getCategoryBreakdown(period)
            ]);

            setTotals(periodTotals);
            setTopCategories(top);
            setAllCategories(all);
        } catch (error) {
            console.error('Error loading dashboard data:', error);
        } finally {
            setLoading(false);
        }
    };

    const periodOptions = [
        { value: 'day', label: 'Aujourd\'hui' },
        { value: 'week', label: 'Cette semaine' },
        { value: 'month', label: 'Ce mois-ci' }
    ];

    return (
        <div className="pb-20">
            <Header
                title="Tableau de bord"
                action={
                    <div className="flex gap-2">
                        <button
                            onClick={toggleSOS}
                            className={`px-3 py-1 text-sm font-bold rounded-lg transition-colors ${sosAmount > 0
                                ? 'bg-red-100 text-red-600 border border-red-200 animate-pulse'
                                : 'bg-gray-100 text-gray-600'}`}
                        >
                            {sosAmount > 0 ? '⚠️ SOS' : '🆘'}
                        </button>
                        <Select
                            value={period}
                            onChange={(e) => setPeriod(e.target.value as Period)}
                            options={periodOptions}
                            className="text-sm h-9 px-3"
                        />
                    </div>
                }
            />

            <div className="p-4 space-y-4">
                {loading ? (
                    <div className="text-center py-12 text-gray-500">
                        Chargement...
                    </div>
                ) : (
                    <>
                        <SummaryCard
                            income={totals.income}
                            expenses={totals.expenses}
                            balance={totals.balance}
                            currency={currency}
                            sosAmount={sosAmount}
                        />

                        <TopCategories categories={topCategories} currency={currency} />

                        <CategoryPieChart data={allCategories} currency={currency} />
                    </>
                )}
            </div>
        </div>
    );
}

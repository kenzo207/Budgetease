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
                    <Select
                        value={period}
                        onChange={(e) => setPeriod(e.target.value as Period)}
                        options={periodOptions}
                        className="text-sm h-9 px-3"
                    />
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
                        />

                        <TopCategories categories={topCategories} currency={currency} />

                        <CategoryPieChart data={allCategories} currency={currency} />
                    </>
                )}
            </div>
        </div>
    );
}

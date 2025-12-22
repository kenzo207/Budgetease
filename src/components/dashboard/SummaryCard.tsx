import React from 'react';
import { Card } from '../ui/Card';
import { formatCurrency } from '../../lib/currency';
import { Currency } from '../../types';
import { TrendingUp, TrendingDown, Wallet } from 'lucide-react';

interface SummaryCardProps {
    income: number;
    expenses: number;
    balance: number;
    currency: Currency;
}

export function SummaryCard({ income, expenses, balance, currency }: SummaryCardProps) {
    return (
        <Card className="bg-gradient-to-br from-primary to-blue-600 text-white">
            <div className="space-y-4">
                <div className="flex items-center justify-between">
                    <div>
                        <p className="text-sm opacity-90">Solde</p>
                        <p className="text-2xl font-semibold mt-1">
                            {formatCurrency(balance, currency)}
                        </p>
                    </div>
                    <Wallet size={32} className="opacity-80" />
                </div>

                <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/20">
                    <div>
                        <div className="flex items-center gap-1.5 text-sm opacity-90">
                            <TrendingUp size={16} />
                            <span>Revenus</span>
                        </div>
                        <p className="text-lg font-medium mt-1">
                            {formatCurrency(income, currency)}
                        </p>
                    </div>

                    <div>
                        <div className="flex items-center gap-1.5 text-sm opacity-90">
                            <TrendingDown size={16} />
                            <span>Dépenses</span>
                        </div>
                        <p className="text-lg font-medium mt-1">
                            {formatCurrency(expenses, currency)}
                        </p>
                    </div>
                </div>
            </div>
        </Card>
    );
}

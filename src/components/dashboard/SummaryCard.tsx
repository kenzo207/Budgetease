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
    sosAmount?: number;
}

export function SummaryCard({ income, expenses, balance, currency, sosAmount = 0 }: SummaryCardProps) {
    const isSosActive = sosAmount > 0;
    const realBalance = balance - sosAmount;

    return (
        <Card className={`text-white transition-colors duration-300 ${isSosActive ? 'bg-gradient-to-br from-red-600 to-red-800' : 'bg-gradient-to-br from-primary to-blue-600'}`}>
            <div className="space-y-4">
                <div className="flex items-center justify-between">
                    <div>
                        <div className="flex items-center gap-2">
                            <p className="text-sm opacity-90">
                                {isSosActive ? 'Reste à vivre (Mode SOS)' : 'Solde'}
                            </p>
                            {isSosActive && (
                                <span className="bg-white/20 px-2 py-0.5 rounded text-xs font-bold animate-pulse">
                                    ⚠️ URGENCE
                                </span>
                            )}
                        </div>
                        <p className="text-2xl font-semibold mt-1">
                            {formatCurrency(realBalance, currency)}
                            {isSosActive && <span className="text-sm font-normal opacity-75 block">({formatCurrency(balance, currency)} réels)</span>}
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

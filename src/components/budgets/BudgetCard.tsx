import React from 'react';
import { Card } from '../ui/Card';
import { ProgressBar } from '../ui/ProgressBar';
import { BudgetProgress, Currency } from '../../types';
import { formatCurrency } from '../../lib/currency';
import { AlertTriangle } from 'lucide-react';

interface BudgetCardProps {
    budget: BudgetProgress;
    currency: Currency;
    onClick?: () => void;
}

export function BudgetCard({ budget, currency, onClick }: BudgetCardProps) {
    return (
        <Card onClick={onClick}>
            <div className="space-y-3">
                <div className="flex items-start justify-between">
                    <div>
                        <h3 className="font-semibold text-gray-900">{budget.category}</h3>
                        <p className="text-sm text-gray-600 mt-0.5">
                            {formatCurrency(budget.spent, currency)} / {formatCurrency(budget.budget, currency)}
                        </p>
                    </div>
                    {budget.status === 'exceeded' && (
                        <AlertTriangle size={20} className="text-danger" />
                    )}
                </div>

                <ProgressBar
                    value={budget.spent}
                    max={budget.budget}
                    status={budget.status}
                    showLabel={false}
                />

                <div className="flex justify-between items-center text-sm">
                    <span className={`font-medium ${budget.status === 'exceeded' ? 'text-danger' :
                            budget.status === 'warning' ? 'text-warning' :
                                'text-success'
                        }`}>
                        {budget.status === 'exceeded'
                            ? `Dépassé de ${formatCurrency(Math.abs(budget.remaining), currency)}`
                            : `Reste ${formatCurrency(budget.remaining, currency)}`
                        }
                    </span>
                    <span className="text-gray-600">
                        {Math.round(budget.percentage)}%
                    </span>
                </div>
            </div>
        </Card>
    );
}

import React from 'react';
import { Card } from '../ui/Card';
import { ProgressBar } from '../ui/ProgressBar';
import { CategoryTotal, Currency } from '../../types';
import { formatCurrency } from '../../lib/currency';

interface TopCategoriesProps {
    categories: CategoryTotal[];
    currency: Currency;
}

export function TopCategories({ categories, currency }: TopCategoriesProps) {
    if (categories.length === 0) {
        return (
            <Card>
                <h3 className="text-base font-semibold text-gray-900 mb-3">Top catégories</h3>
                <p className="text-sm text-gray-500 text-center py-8">
                    Aucune dépense enregistrée
                </p>
            </Card>
        );
    }

    return (
        <Card>
            <h3 className="text-base font-semibold text-gray-900 mb-4">Top catégories</h3>
            <div className="space-y-4">
                {categories.map((cat, index) => (
                    <div key={index}>
                        <div className="flex justify-between items-center mb-1.5">
                            <span className="text-sm font-medium text-gray-700">{cat.category}</span>
                            <span className="text-sm font-semibold text-gray-900">
                                {formatCurrency(cat.total, currency)}
                            </span>
                        </div>
                        <ProgressBar
                            value={cat.percentage}
                            max={100}
                            status="safe"
                            showLabel={false}
                        />
                        <span className="text-xs text-gray-500 mt-0.5 block">
                            {Math.round(cat.percentage)}% du total
                        </span>
                    </div>
                ))}
            </div>
        </Card>
    );
}

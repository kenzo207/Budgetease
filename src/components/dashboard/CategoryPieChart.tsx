import React from 'react';
import { PieChart as RechartsPieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';
import { Card } from '../ui/Card';
import { CategoryTotal, Currency } from '../../types';
import { formatCurrency } from '../../lib/currency';

interface CategoryPieChartProps {
    data: CategoryTotal[];
    currency: Currency;
}

const COLORS = ['#2563EB', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6'];

export function CategoryPieChart({ data, currency }: CategoryPieChartProps) {
    if (data.length === 0) {
        return (
            <Card>
                <h3 className="text-base font-semibold text-gray-900 mb-3">Répartition</h3>
                <p className="text-sm text-gray-500 text-center py-8">
                    Aucune donnée à afficher
                </p>
            </Card>
        );
    }

    const chartData = data.map(item => ({
        name: item.category,
        value: item.total
    }));

    return (
        <Card>
            <h3 className="text-base font-semibold text-gray-900 mb-4">Répartition</h3>
            <ResponsiveContainer width="100%" height={250}>
                <RechartsPieChart>
                    <Pie
                        data={chartData}
                        cx="50%"
                        cy="50%"
                        labelLine={false}
                        label={({ name, percent }) => `${name} ${((percent || 0) * 100).toFixed(0)}%`}
                        outerRadius={80}
                        fill="#8884d8"
                        dataKey="value"
                    >
                        {chartData.map((entry, index) => (
                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                        ))}
                    </Pie>
                    <Tooltip
                        formatter={(value: number | undefined) => formatCurrency(value || 0, currency)}
                    />
                </RechartsPieChart>
            </ResponsiveContainer>
        </Card>
    );
}

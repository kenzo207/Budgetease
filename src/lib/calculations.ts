import { db } from './db';
import { Period, PeriodTotals, CategoryTotal, BudgetProgress } from '../types';
import { startOfDay, startOfWeek, startOfMonth, endOfDay, endOfWeek, endOfMonth } from 'date-fns';

export async function getPeriodTotals(period: Period): Promise<PeriodTotals> {
    const now = new Date();
    let startDate: Date;
    let endDate: Date;

    switch (period) {
        case 'day':
            startDate = startOfDay(now);
            endDate = endOfDay(now);
            break;
        case 'week':
            startDate = startOfWeek(now, { weekStartsOn: 1 }); // Monday
            endDate = endOfWeek(now, { weekStartsOn: 1 });
            break;
        case 'month':
            startDate = startOfMonth(now);
            endDate = endOfMonth(now);
            break;
    }

    const transactions = await db.transactions
        .where('date')
        .between(startDate, endDate, true, true)
        .toArray();

    const income = transactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0);

    const expenses = transactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0);

    return {
        income,
        expenses,
        balance: income - expenses
    };
}

export async function getTopCategories(limit: number = 3, period: Period = 'month'): Promise<CategoryTotal[]> {
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
    }

    const transactions = await db.transactions
        .where('date')
        .aboveOrEqual(startDate)
        .and(t => t.type === 'expense')
        .toArray();

    const categoryTotals = transactions.reduce((acc, t) => {
        acc[t.category] = (acc[t.category] || 0) + t.amount;
        return acc;
    }, {} as Record<string, number>);

    const totalExpenses = Object.values(categoryTotals).reduce((sum, val) => sum + val, 0);

    const result = Object.entries(categoryTotals)
        .map(([category, total]) => ({
            category,
            total,
            percentage: totalExpenses > 0 ? (total / totalExpenses) * 100 : 0
        }))
        .sort((a, b) => b.total - a.total)
        .slice(0, limit);

    return result;
}

export async function getCategoryBreakdown(period: Period = 'month'): Promise<CategoryTotal[]> {
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
    }

    const transactions = await db.transactions
        .where('date')
        .aboveOrEqual(startDate)
        .and(t => t.type === 'expense')
        .toArray();

    const categoryTotals = transactions.reduce((acc, t) => {
        acc[t.category] = (acc[t.category] || 0) + t.amount;
        return acc;
    }, {} as Record<string, number>);

    const totalExpenses = Object.values(categoryTotals).reduce((sum, val) => sum + val, 0);

    return Object.entries(categoryTotals)
        .map(([category, total]) => ({
            category,
            total,
            percentage: totalExpenses > 0 ? (total / totalExpenses) * 100 : 0
        }))
        .sort((a, b) => b.total - a.total);
}

export async function getBudgetProgress(category: string, month?: string): Promise<BudgetProgress | null> {
    const targetMonth = month || new Date().toISOString().slice(0, 7); // YYYY-MM

    const budget = await db.budgets
        .where('category')
        .equals(category)
        .and(b => b.month === targetMonth)
        .first();

    if (!budget) return null;

    const [year, monthNum] = targetMonth.split('-').map(Number);
    const startDate = new Date(year, monthNum - 1, 1);
    const endDate = new Date(year, monthNum, 0, 23, 59, 59);

    const transactions = await db.transactions
        .where('date')
        .between(startDate, endDate, true, true)
        .and(t => t.type === 'expense' && t.category === category)
        .toArray();

    const spent = transactions.reduce((sum, t) => sum + t.amount, 0);
    const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
    const remaining = budget.amount - spent;

    let status: 'safe' | 'warning' | 'exceeded';
    if (percentage >= 100) {
        status = 'exceeded';
    } else if (percentage >= 80) {
        status = 'warning';
    } else {
        status = 'safe';
    }

    return {
        category,
        spent,
        budget: budget.amount,
        percentage,
        remaining,
        status
    };
}

export async function getAllBudgetsProgress(month?: string): Promise<BudgetProgress[]> {
    const targetMonth = month || new Date().toISOString().slice(0, 7);

    const budgets = await db.budgets
        .where('month')
        .equals(targetMonth)
        .toArray();

    const progressPromises = budgets.map(b => getBudgetProgress(b.category, targetMonth));
    const results = await Promise.all(progressPromises);

    return results.filter((p): p is BudgetProgress => p !== null);
}

export function getMonthlyFixedCharges(charges: any[]): number {
    let total = 0;
    for (const charge of charges) {
        if (!charge.isActive) continue;

        switch (charge.frequency) {
            case 'daily':
                total += charge.amount * 30;
                break;
            case 'weekly':
                total += charge.amount * 4.33;
                break;
            case 'monthly':
                total += charge.amount;
                break;
            case 'yearly':
                total += charge.amount / 12;
                break;
        }
    }
    return total;
}

export function getRealAvailableBudget(
    totalIncome: number,
    totalFixedCharges: number,
    totalExpenses: number,
    savingsGoal: number = 0
) {
    // Reste pour Dépenses Variables (RDV)
    const rdv = totalIncome - totalFixedCharges - savingsGoal;

    // Argent Réellement Disponible (ARD)
    const ard = rdv - totalExpenses;

    return {
        rdv,
        ard,
        fixed: totalFixedCharges,
        saved: savingsGoal
    };
}

import { db } from './db';
import { GhostMoneyInsight } from '../types';
import { getPeriodTotals } from './calculations';

// Configuration constants
const MICRO_EXPENSE_THRESHOLD = 500; // FCFA
const MIN_TRANSACTION_COUNT = 5;
const MIN_IMPACT_PERCENTAGE = 5; // %
const ANALYSIS_PERIOD_DAYS = 7;

/**
 * Detect ghost money patterns (repeated micro-expenses)
 */
export async function detectGhostMoney(): Promise<GhostMoneyInsight | null> {
    const now = new Date();
    const weekAgo = new Date(now);
    weekAgo.setDate(weekAgo.getDate() - ANALYSIS_PERIOD_DAYS);

    // Get micro-expenses from last week
    const microExpenses = await db.transactions
        .where('date')
        .above(weekAgo)
        .and(t => t.type === 'expense' && t.amount <= MICRO_EXPENSE_THRESHOLD)
        .toArray();

    // Trigger threshold: at least 5 transactions
    if (microExpenses.length < MIN_TRANSACTION_COUNT) return null;

    const total = microExpenses.reduce((sum, t) => sum + t.amount, 0);
    const categories = [...new Set(microExpenses.map(t => t.category))];

    // Calculate relative impact vs available money
    const ard = await getRealAvailableBudget();

    // If no money available, no relevant insight
    if (ard <= 0) return null;

    const impact = (total / ard) * 100;

    // Only trigger if impact > minimum threshold
    if (impact < MIN_IMPACT_PERCENTAGE) return null;

    return {
        detectedAt: now,
        totalAmount: total,
        transactionCount: microExpenses.length,
        categoryNames: categories,
        periodDays: ANALYSIS_PERIOD_DAYS,
        percentageOfAvailable: impact,
    };
}

/**
 * Get or create current ghost money insight
 */
export async function getOrCreateGhostMoneyInsight(): Promise<GhostMoneyInsight | null> {
    // Clean old insights (> 7 days)
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    await db.ghostMoneyInsights
        .where('detectedAt')
        .below(weekAgo)
        .delete();

    // Check for existing recent insight
    const existing = await db.ghostMoneyInsights
        .where('detectedAt')
        .above(weekAgo)
        .first();

    if (existing) return existing;

    // Detect new pattern
    const newInsight = await detectGhostMoney();
    if (newInsight) {
        await db.ghostMoneyInsights.add(newInsight);
    }

    return newInsight;
}

/**
 * Get all active insights
 */
export async function getActiveGhostMoneyInsights(): Promise<GhostMoneyInsight[]> {
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    return db.ghostMoneyInsights
        .where('detectedAt')
        .above(weekAgo)
        .toArray();
}

/**
 * Dismiss an insight
 */
export async function dismissGhostMoneyInsight(id: number): Promise<void> {
    await db.ghostMoneyInsights.delete(id);
}

/**
 * Calculate real available budget
 */
async function getRealAvailableBudget(): Promise<number> {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const transactions = await db.transactions.toArray();
    const totals = getPeriodTotals(transactions, startOfMonth, now);

    return totals.balance;
}

/**
 * Get severity level based on impact
 */
export function getGhostMoneySeverity(insight: GhostMoneyInsight): 'low' | 'medium' | 'high' {
    if (insight.percentageOfAvailable > 15) return 'high';
    if (insight.percentageOfAvailable > 8) return 'medium';
    return 'low';
}

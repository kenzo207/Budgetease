import { db } from './db';
import { Transaction, IncomePattern } from '../types';

const PATTERN_ID = 'current';

/**
 * Calculate variance of an array of numbers
 */
function calculateVariance(numbers: number[]): number {
    if (numbers.length === 0) return 0;
    const mean = numbers.reduce((a, b) => a + b, 0) / numbers.length;
    const squaredDiffs = numbers.map(x => Math.pow(x - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b, 0) / numbers.length;
}

/**
 * Analyze income pattern over last 14 days
 */
export async function analyzeIncomePattern(): Promise<IncomePattern> {
    const now = new Date();
    const twoWeeksAgo = new Date(now);
    twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);

    const incomes = await db.transactions
        .where('date')
        .above(twoWeeksAgo)
        .and(t => t.type === 'income')
        .toArray();

    if (incomes.length === 0) {
        // No recent income: prudent mode
        return {
            id: PATTERN_ID,
            estimatedWeeklyIncome: 0,
            minimumObserved: 0,
            averageObserved: 0,
            observationDays: 14,
            lastUpdated: now,
            isRegular: false,
        };
    }

    const total = incomes.reduce((sum, t) => sum + t.amount, 0);
    const average = total / 2; // Average over 2 weeks
    const minimum = Math.min(...incomes.map(t => t.amount));

    // Detect regularity: low variance
    const amounts = incomes.map(t => t.amount);
    const variance = calculateVariance(amounts);
    const isRegular = variance < (average * 0.3); // Variance < 30%

    // Prudent estimate: use minimum if irregular
    const estimate = isRegular ? average : minimum;

    return {
        id: PATTERN_ID,
        estimatedWeeklyIncome: estimate,
        minimumObserved: minimum,
        averageObserved: average,
        observationDays: 14,
        lastUpdated: now,
        isRegular,
    };
}

/**
 * Get or create income pattern
 */
export async function getOrCreateIncomePattern(): Promise<IncomePattern> {
    const existing = await db.income_patterns.get(PATTERN_ID);

    if (existing) {
        // Update if more than 24h old
        const hoursSinceUpdate = (Date.now() - new Date(existing.lastUpdated).getTime()) / (1000 * 60 * 60);
        if (hoursSinceUpdate > 24) {
            const updated = await analyzeIncomePattern();
            await db.income_patterns.put(updated);
            return updated;
        }
        return existing;
    }

    // Create new pattern
    const pattern = await analyzeIncomePattern();
    await db.income_patterns.add(pattern);
    return pattern;
}

/**
 * Get estimated monthly income
 */
export function getEstimatedMonthlyIncome(pattern: IncomePattern): number {
    return pattern.estimatedWeeklyIncome * 4.33;
}

/**
 * Get confidence level (0-1)
 */
export function getConfidenceLevel(pattern: IncomePattern): number {
    if (pattern.observationDays < 7) return 0.3;
    if (pattern.observationDays < 14) return 0.6;
    if (pattern.isRegular) return 0.9;
    return 0.7;
}

/**
 * Estimate next income
 */
export function estimateNextIncome(pattern: IncomePattern): {
    amount: number;
    daysUntil: number;
    confidence: 'low' | 'medium' | 'high';
} {
    if (pattern.estimatedWeeklyIncome === 0) {
        return {
            amount: 0,
            daysUntil: 7,
            confidence: 'low',
        };
    }

    const daysUntil = pattern.isRegular ? 7 : 14;

    return {
        amount: pattern.estimatedWeeklyIncome,
        daysUntil,
        confidence: pattern.isRegular ? 'high' : 'medium',
    };
}

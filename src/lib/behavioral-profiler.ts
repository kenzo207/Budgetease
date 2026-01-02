import { db } from './db';
import { Transaction, BehavioralProfile } from '../types';
import { getRecommendedDailyCap } from './calculations';

const PROFILE_USER_ID = 'local';

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
 * Get daily spending for a specific date
 */
async function getDailySpent(date: Date): Promise<number> {
    const startOfDay = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    const transactions = await db.transactions
        .where('date')
        .between(startOfDay, endOfDay)
        .and(t => t.type === 'expense')
        .toArray();

    return transactions.reduce((sum, t) => sum + t.amount, 0);
}

/**
 * Build behavioral profile based on last 30 days
 */
export async function buildBehavioralProfile(): Promise<BehavioralProfile> {
    const now = new Date();
    const last30Days = new Date(now);
    last30Days.setDate(last30Days.getDate() - 30);

    const recentTransactions = await db.transactions
        .where('date')
        .above(last30Days)
        .toArray();

    // Calculate spending frequency
    const frequency = recentTransactions.length / 30;

    // Build hourly pattern
    const hourlyPattern: Record<number, number> = {};
    recentTransactions.forEach(t => {
        const hour = new Date(t.date).getHours();
        hourlyPattern[hour] = (hourlyPattern[hour] || 0) + 1;
    });

    // Analyze overruns
    let overruns = 0;
    let totalOverrun = 0;

    for (let i = 0; i < 30; i++) {
        const day = new Date(now);
        day.setDate(day.getDate() - i);
        const dailyCap = await getRecommendedDailyCap();
        const spent = await getDailySpent(day);

        if (spent > dailyCap && dailyCap > 0) {
            overruns++;
            totalOverrun += (spent - dailyCap);
        }
    }

    return {
        id: PROFILE_USER_ID,
        userId: PROFILE_USER_ID,
        spendingFrequency: frequency,
        hourlyPattern,
        overrunCount: overruns,
        averageOverrun: overruns > 0 ? totalOverrun / overruns : 0,
        lastUpdated: now,
    };
}

/**
 * Get or create behavioral profile
 */
export async function getOrCreateBehavioralProfile(): Promise<BehavioralProfile> {
    const existing = await db.behavioralProfiles.get(PROFILE_USER_ID);

    if (existing) {
        // Update if more than 24h old
        const hoursSinceUpdate = (Date.now() - new Date(existing.lastUpdated).getTime()) / (1000 * 60 * 60);
        if (hoursSinceUpdate > 24) {
            const updated = await buildBehavioralProfile();
            await db.behavioralProfiles.put(updated);
            return updated;
        }
        return existing;
    }

    // Create new profile
    const profile = await buildBehavioralProfile();
    await db.behavioralProfiles.add(profile);
    return profile;
}

/**
 * Calculate risk score (0 = disciplined, 1 = at risk)
 */
export function getRiskScore(profile: BehavioralProfile): number {
    const frequencyScore = profile.spendingFrequency > 5 ? 0.3 : 0;
    const overrunScore = profile.overrunCount > 10 ? 0.4 : (profile.overrunCount / 25);
    const eveningScore = (profile.hourlyPattern[20] || 0) > 3 ? 0.3 : 0;

    return Math.min(frequencyScore + overrunScore + eveningScore, 1.0);
}

/**
 * Get advice level based on risk score
 */
export function getAdviceLevel(profile: BehavioralProfile): 'minimal' | 'standard' | 'frequent' {
    const riskScore = getRiskScore(profile);
    if (riskScore > 0.6) return 'frequent';
    if (riskScore < 0.3) return 'minimal';
    return 'standard';
}

/**
 * Check if user tends to spend in the evening
 */
export function isEveningSpender(profile: BehavioralProfile): boolean {
    const eveningTransactions =
        (profile.hourlyPattern[18] || 0) +
        (profile.hourlyPattern[19] || 0) +
        (profile.hourlyPattern[20] || 0) +
        (profile.hourlyPattern[21] || 0);

    const totalTransactions = Object.values(profile.hourlyPattern).reduce((a, b) => a + b, 0);

    return totalTransactions > 0 && (eveningTransactions / totalTransactions) > 0.4;
}

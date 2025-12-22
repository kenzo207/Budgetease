import { db } from './db';
import { RecurringTransaction, Transaction } from '../types';
import { startOfMonth, endOfMonth, addDays, addWeeks, addMonths, isBefore, isAfter } from 'date-fns';

export async function generateRecurringTransactions(month?: string): Promise<number> {
    const targetMonth = month || new Date().toISOString().slice(0, 7);
    const [year, monthNum] = targetMonth.split('-').map(Number);
    const startDate = new Date(year, monthNum - 1, 1);
    const endDate = new Date(year, monthNum, 0);

    const recurring = await db.recurring
        .where('isActive')
        .equals(1)
        .toArray();

    let generatedCount = 0;

    for (const rec of recurring) {
        const occurrences = getOccurrencesForMonth(rec, startDate, endDate);

        for (const date of occurrences) {
            // Check if already exists
            const existing = await db.transactions
                .where('date')
                .equals(date)
                .and(t =>
                    t.type === rec.type &&
                    t.category === rec.category &&
                    t.amount === rec.amount &&
                    t.paymentMethod === rec.paymentMethod
                )
                .first();

            if (!existing) {
                const transaction: Transaction = {
                    type: rec.type,
                    amount: rec.amount,
                    category: rec.category,
                    paymentMethod: rec.paymentMethod,
                    date,
                    note: rec.note,
                    createdAt: new Date()
                };

                await db.transactions.add(transaction);
                generatedCount++;
            }
        }

        // Update lastGenerated
        await db.recurring.update(rec.id!, { lastGenerated: new Date() });
    }

    return generatedCount;
}

function getOccurrencesForMonth(
    rec: RecurringTransaction,
    startDate: Date,
    endDate: Date
): Date[] {
    const occurrences: Date[] = [];

    switch (rec.frequency) {
        case 'daily':
            let currentDay = new Date(startDate);
            while (isBefore(currentDay, endDate) || currentDay.toDateString() === endDate.toDateString()) {
                occurrences.push(new Date(currentDay));
                currentDay = addDays(currentDay, 1);
            }
            break;

        case 'weekly':
            if (rec.dayOfWeek !== undefined) {
                let current = new Date(startDate);
                // Find first occurrence of the day of week
                while (current.getDay() !== rec.dayOfWeek) {
                    current = addDays(current, 1);
                }

                while (isBefore(current, endDate) || current.toDateString() === endDate.toDateString()) {
                    occurrences.push(new Date(current));
                    current = addWeeks(current, 1);
                }
            }
            break;

        case 'monthly':
            if (rec.dayOfMonth !== undefined) {
                const day = Math.min(rec.dayOfMonth, endDate.getDate());
                const occurrence = new Date(startDate.getFullYear(), startDate.getMonth(), day);

                if (!isBefore(occurrence, startDate) && !isAfter(occurrence, endDate)) {
                    occurrences.push(occurrence);
                }
            }
            break;
    }

    return occurrences;
}

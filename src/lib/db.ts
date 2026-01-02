import Dexie, { Table } from 'dexie';
import {
    Transaction,
    Budget,
    Category,
    Settings,
    FixedCharge,
    RecurringTransaction,
    BehavioralProfile,
    IncomePattern,
    GhostMoneyInsight
} from '../types';

export class BudgetEaseDB extends Dexie {
    transactions!: Table<Transaction>;
    budgets!: Table<Budget>;
    recurring!: Table<RecurringTransaction>;
    categories!: Table<Category>;
    settings!: Table<Settings>;
    fixedCharges!: Table<FixedCharge>;
    behavioralProfiles!: Table<BehavioralProfile>;
    incomePatterns!: Table<IncomePattern>;
    ghostMoneyInsights!: Table<GhostMoneyInsight>;

    constructor() {
        super('BudgetEaseDB');

        // Version 1: Original schema
        this.version(1).stores({
            transactions: '++id, type, amount, category, date',
            budgets: '++id, category, amount, month',
            recurring: '++id, category, frequency, isActive',
            categories: '++id, &name, isDefault',
            settings: '++id',
            fixedCharges: '++id, title, isActive'
        });

        // Version 2: Add Smart Coach V3 tables
        this.version(2).stores({
            transactions: '++id, type, amount, category, date',
            budgets: '++id, category, amount, month',
            recurring: '++id, category, frequency, isActive',
            categories: '++id, &name, isDefault',
            settings: '++id',
            fixedCharges: '++id, title, isActive',
            behavioralProfiles: '&id, userId, lastUpdated',
            incomePatterns: '&id, lastUpdated',
            ghostMoneyInsights: '++id, detectedAt'
        });
    }
}

export const db = new BudgetEaseDB();

// Initialize default data
export async function initializeDefaultData() {
    const settingsCount = await db.settings.count();

    if (settingsCount === 0) {
        // Create default settings
        await db.settings.add({
            currency: 'FCFA',
            notificationEnabled: false,
            notificationTime: '20:00',
            onboardingCompleted: false,
            favoriteCategories: []
        });
    }

    const categoriesCount = await db.categories.count();

    if (categoriesCount === 0) {
        // Add default categories
        const defaultCategories = [
            { name: 'Mobile Money', icon: '📱', isDefault: true, createdAt: new Date() },
            { name: 'Transport', icon: '🚕', isDefault: true, createdAt: new Date() },
            { name: 'Alimentation', icon: '🍔', isDefault: true, createdAt: new Date() },
            { name: 'Internet', icon: '🌐', isDefault: true, createdAt: new Date() },
            { name: 'Santé', icon: '💊', isDefault: true, createdAt: new Date() },
            { name: 'Logement', icon: '🏠', isDefault: true, createdAt: new Date() },
            { name: 'Éducation', icon: '📚', isDefault: true, createdAt: new Date() },
            { name: 'Loisirs', icon: '🎮', isDefault: true, createdAt: new Date() },
            { name: 'Autres', icon: '📦', isDefault: true, createdAt: new Date() }
        ];

        await db.categories.bulkAdd(defaultCategories);
    }
}

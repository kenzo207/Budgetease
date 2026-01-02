export type TransactionType = 'expense' | 'income';
export type PaymentMethod = 'MoMo' | 'Cash' | 'Carte';
export type Currency = 'FCFA' | 'NGN' | 'GHS' | 'USD' | 'EUR';
export type Period = 'day' | 'week' | 'month';
export type RecurringFrequency = 'daily' | 'weekly' | 'monthly';

export interface Transaction {
    id?: number;
    type: TransactionType;
    amount: number;
    category: string;
    paymentMethod: PaymentMethod;
    date: Date;
    note?: string;
    createdAt: Date;
    shadowSavings?: number; // Optional for compatibility with existing data
}

export interface Budget {
    id?: number;
    category: string;
    amount: number;
    month: string; // Format: YYYY-MM
    createdAt: Date;
}

export interface RecurringTransaction {
    id?: number;
    type: TransactionType;
    amount: number;
    category: string;
    paymentMethod: PaymentMethod;
    frequency: RecurringFrequency;
    dayOfMonth?: number; // For monthly (1-31)
    dayOfWeek?: number; // For weekly (0-6)
    note?: string;
    lastGenerated?: Date;
    isActive: boolean;
    createdAt: Date;
}

export interface Category {
    id?: number;
    name: string;
    icon: string;
    isDefault: boolean;
    createdAt: Date;
}

export interface FixedCharge {
    id?: number;
    title: string;
    amount: number;
    frequency: 'daily' | 'weekly' | 'monthly' | 'yearly';
    nextDueDate: Date;
    isActive: boolean;
    categoryId?: string;
}

export interface Settings {
    id?: number;
    currency: Currency;
    notificationEnabled: boolean;
    notificationTime: string; // Format: HH:mm
    onboardingCompleted: boolean;
    favoriteCategories: string[];
    sosAmount?: number;
}

export interface CategoryTotal {
    category: string;
    total: number;
    percentage: number;
}

export interface PeriodTotals {
    income: number;
    expenses: number;
    balance: number;
}

export interface BudgetProgress {
    category: string;
    spent: number;
    budget: number;
    percentage: number;
    remaining: number;
    status: 'safe' | 'warning' | 'exceeded';
}

export interface ChartDataPoint {
    name: string;
    value: number;
    date?: string;
}

// Smart Coach V3 Types
export interface BehavioralProfile {
    id: string;
    userId: string; // Always "local" for MVP
    spendingFrequency: number; // Transactions per day
    hourlyPattern: Record<number, number>; // Hour -> Transaction count
    overrunCount: number; // Overruns in last 30 days
    averageOverrun: number; // Average overrun amount
    lastUpdated: Date;
}

export interface IncomePattern {
    id: string;
    estimatedWeeklyIncome: number;
    minimumObserved: number;
    averageObserved: number;
    observationDays: number;
    lastUpdated: Date;
    isRegular: boolean; // true if stable pattern detected
}

export interface GhostMoneyInsight {
    id?: number;
    detectedAt: Date;
    totalAmount: number;
    transactionCount: number;
    categoryNames: string[];
    periodDays: number; // 7 by default
    percentageOfAvailable: number; // Relative impact
}

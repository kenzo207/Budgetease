import { Currency } from '../types';

export const CURRENCIES: Record<Currency, { symbol: string; name: string; locale: string }> = {
    FCFA: { symbol: 'FCFA', name: 'Franc CFA', locale: 'fr-BJ' },
    NGN: { symbol: '₦', name: 'Naira', locale: 'en-NG' },
    GHS: { symbol: '₵', name: 'Cedi', locale: 'en-GH' },
    USD: { symbol: '$', name: 'Dollar', locale: 'en-US' },
    EUR: { symbol: '€', name: 'Euro', locale: 'fr-FR' }
};

export function formatCurrency(amount: number, currency: Currency): string {
    const config = CURRENCIES[currency];

    // For FCFA, use custom formatting (no decimals, space before symbol)
    if (currency === 'FCFA') {
        return `${amount.toLocaleString('fr-BJ', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        })} ${config.symbol}`;
    }

    // For other currencies, use standard Intl formatting
    return new Intl.NumberFormat(config.locale, {
        style: 'currency',
        currency: currency === 'NGN' ? 'NGN' : currency === 'GHS' ? 'GHS' : currency,
        minimumFractionDigits: 0,
        maximumFractionDigits: 2
    }).format(amount);
}

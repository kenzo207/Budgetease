import { db } from './db';
import { Transaction } from '../types';
import { parse } from 'papaparse';

export async function exportToCSV(month?: string): Promise<void> {
    let transactions: Transaction[];

    if (month) {
        const [year, monthNum] = month.split('-').map(Number);
        const startDate = new Date(year, monthNum - 1, 1);
        const endDate = new Date(year, monthNum, 0, 23, 59, 59);

        transactions = await db.transactions
            .where('date')
            .between(startDate, endDate, true, true)
            .toArray();
    } else {
        transactions = await db.transactions.toArray();
    }

    // Prepare CSV data
    const csvData = transactions.map(t => ({
        Date: new Date(t.date).toLocaleDateString('fr-FR'),
        Type: t.type === 'expense' ? 'Dépense' : 'Revenu',
        Montant: t.amount,
        Catégorie: t.category,
        'Moyen de paiement': t.paymentMethod,
        Note: t.note || ''
    }));

    // Convert to CSV string
    const headers = ['Date', 'Type', 'Montant', 'Catégorie', 'Moyen de paiement', 'Note'];
    const csvRows = [
        headers.join(','),
        ...csvData.map(row =>
            headers.map(header => {
                const value = row[header as keyof typeof row];
                // Escape commas and quotes
                const escaped = String(value).replace(/"/g, '""');
                return `"${escaped}"`;
            }).join(',')
        )
    ];

    const csvString = csvRows.join('\n');

    // Create download
    const blob = new Blob(['\uFEFF' + csvString], { type: 'text/csv;charset=utf-8;' }); // BOM for Excel
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);

    link.setAttribute('href', url);
    link.setAttribute('download', `budgetease_${month || 'toutes'}_${Date.now()}.csv`);
    link.style.visibility = 'hidden';

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

import React from 'react';
import { Transaction, Currency } from '../../types';
import { formatCurrency } from '../../lib/currency';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { MoreVertical, Pencil, Trash2 } from 'lucide-react';

interface TransactionItemProps {
    transaction: Transaction;
    currency: Currency;
    onEdit: (transaction: Transaction) => void;
    onDelete: (id: number) => void;
}

export function TransactionItem({ transaction, currency, onEdit, onDelete }: TransactionItemProps) {
    const [showMenu, setShowMenu] = React.useState(false);

    const handleDelete = () => {
        if (window.confirm('Supprimer cette transaction ?')) {
            onDelete(transaction.id!);
        }
    };

    return (
        <div className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-lg hover:shadow-sm transition-shadow">
            <div className="flex-1">
                <div className="flex items-center gap-2">
                    <span className="text-lg">{getCategoryIcon(transaction.category)}</span>
                    <div>
                        <p className="font-medium text-gray-900">{transaction.category}</p>
                        <p className="text-xs text-gray-500">
                            {transaction.note || transaction.paymentMethod} • {' '}
                            {format(new Date(transaction.date), 'HH:mm', { locale: fr })}
                        </p>
                    </div>
                </div>
            </div>

            <div className="flex items-center gap-3">
                <p className={`font-semibold ${transaction.type === 'income' ? 'text-success' : 'text-gray-900'
                    }`}>
                    {transaction.type === 'income' ? '+' : '-'}
                    {formatCurrency(transaction.amount, currency)}
                </p>

                <div className="relative">
                    <button
                        onClick={() => setShowMenu(!showMenu)}
                        className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
                    >
                        <MoreVertical size={18} />
                    </button>

                    {showMenu && (
                        <>
                            <div
                                className="fixed inset-0 z-10"
                                onClick={() => setShowMenu(false)}
                            />
                            <div className="absolute right-0 top-8 bg-white border border-gray-200 rounded-lg shadow-lg z-20 min-w-[140px]">
                                <button
                                    onClick={() => {
                                        onEdit(transaction);
                                        setShowMenu(false);
                                    }}
                                    className="flex items-center gap-2 w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                                >
                                    <Pencil size={16} />
                                    Modifier
                                </button>
                                <button
                                    onClick={() => {
                                        handleDelete();
                                        setShowMenu(false);
                                    }}
                                    className="flex items-center gap-2 w-full px-4 py-2.5 text-sm text-danger hover:bg-danger-light transition-colors rounded-b-lg"
                                >
                                    <Trash2 size={16} />
                                    Supprimer
                                </button>
                            </div>
                        </>
                    )}
                </div>
            </div>
        </div>
    );
}

function getCategoryIcon(category: string): string {
    const icons: Record<string, string> = {
        'Mobile Money': '📱',
        'Transport': '🚕',
        'Alimentation': '🍔',
        'Internet': '🌐',
        'Santé': '💊',
        'Logement': '🏠',
        'Éducation': '📚',
        'Loisirs': '🎮',
        'Autres': '📦'
    };
    return icons[category] || '📦';
}

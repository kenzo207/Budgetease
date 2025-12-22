import React, { useState, useEffect } from 'react';
import { Header } from '../components/layout/Header';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Select } from '../components/ui/Select';
import { Currency } from '../types';
import { db } from '../lib/db';
import { exportToCSV } from '../lib/export';
import { requestNotificationPermission, scheduleDailyNotification } from '../lib/notifications';
import { Download, Bell, Globe, Trash2 } from 'lucide-react';

export function Settings() {
    const [currency, setCurrency] = useState<Currency>('FCFA');
    const [notificationEnabled, setNotificationEnabled] = useState(false);
    const [notificationTime, setNotificationTime] = useState('20:00');
    const [exporting, setExporting] = useState(false);

    useEffect(() => {
        loadSettings();
    }, []);

    const loadSettings = async () => {
        const settings = await db.settings.toArray();
        if (settings.length > 0) {
            const s = settings[0];
            setCurrency(s.currency);
            setNotificationEnabled(s.notificationEnabled);
            setNotificationTime(s.notificationTime);
        }
    };

    const handleCurrencyChange = async (newCurrency: Currency) => {
        setCurrency(newCurrency);
        const settings = await db.settings.toArray();
        if (settings.length > 0) {
            await db.settings.update(settings[0].id!, { currency: newCurrency });
        }
    };

    const handleNotificationToggle = async () => {
        if (!notificationEnabled) {
            const granted = await requestNotificationPermission();
            if (granted) {
                setNotificationEnabled(true);
                scheduleDailyNotification(notificationTime);

                const settings = await db.settings.toArray();
                if (settings.length > 0) {
                    await db.settings.update(settings[0].id!, { notificationEnabled: true });
                }
            } else {
                alert('Permission refusée. Activez les notifications dans les paramètres de votre navigateur.');
            }
        } else {
            setNotificationEnabled(false);
            const settings = await db.settings.toArray();
            if (settings.length > 0) {
                await db.settings.update(settings[0].id!, { notificationEnabled: false });
            }
        }
    };

    const handleTimeChange = async (time: string) => {
        setNotificationTime(time);
        const settings = await db.settings.toArray();
        if (settings.length > 0) {
            await db.settings.update(settings[0].id!, { notificationTime: time });
        }

        if (notificationEnabled) {
            scheduleDailyNotification(time);
        }
    };

    const handleExport = async () => {
        setExporting(true);
        try {
            const currentMonth = new Date().toISOString().slice(0, 7);
            await exportToCSV(currentMonth);
        } catch (error) {
            console.error('Export error:', error);
            alert('Erreur lors de l\'export');
        } finally {
            setExporting(false);
        }
    };

    const handleReset = async () => {
        if (window.confirm('Êtes-vous sûr de vouloir réinitialiser toutes les données ? Cette action est irréversible.')) {
            if (window.confirm('Dernière confirmation : toutes vos transactions, budgets et paramètres seront supprimés.')) {
                await db.transactions.clear();
                await db.budgets.clear();
                await db.recurring.clear();

                // Reset settings but keep currency
                const settings = await db.settings.toArray();
                if (settings.length > 0) {
                    await db.settings.update(settings[0].id!, {
                        notificationEnabled: false,
                        onboardingCompleted: false,
                        favoriteCategories: []
                    });
                }

                alert('Données réinitialisées');
                window.location.reload();
            }
        }
    };

    const currencyOptions = [
        { value: 'FCFA', label: 'FCFA (Franc CFA)' },
        { value: 'NGN', label: 'NGN (Naira)' },
        { value: 'GHS', label: 'GHS (Cedi)' },
        { value: 'USD', label: 'USD (Dollar)' },
        { value: 'EUR', label: 'EUR (Euro)' }
    ];

    return (
        <div className="pb-20">
            <Header title="Paramètres" />

            <div className="p-4 space-y-4">
                {/* General */}
                <Card>
                    <div className="flex items-center gap-3 mb-4">
                        <Globe size={20} className="text-primary" />
                        <h3 className="font-semibold text-gray-900">Général</h3>
                    </div>

                    <Select
                        label="Devise"
                        value={currency}
                        onChange={(e) => handleCurrencyChange(e.target.value as Currency)}
                        options={currencyOptions}
                    />
                </Card>

                {/* Notifications */}
                <Card>
                    <div className="flex items-center gap-3 mb-4">
                        <Bell size={20} className="text-primary" />
                        <h3 className="font-semibold text-gray-900">Notifications</h3>
                    </div>

                    <div className="space-y-4">
                        <div className="flex items-center justify-between">
                            <span className="text-sm font-medium text-gray-700">Rappel quotidien</span>
                            <button
                                onClick={handleNotificationToggle}
                                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${notificationEnabled ? 'bg-primary' : 'bg-gray-300'
                                    }`}
                            >
                                <span
                                    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${notificationEnabled ? 'translate-x-6' : 'translate-x-1'
                                        }`}
                                />
                            </button>
                        </div>

                        {notificationEnabled && (
                            <div>
                                <label className="text-sm font-medium text-gray-700 block mb-1.5">
                                    Heure du rappel
                                </label>
                                <input
                                    type="time"
                                    value={notificationTime}
                                    onChange={(e) => handleTimeChange(e.target.value)}
                                    className="w-full h-11 px-4 border border-gray-300 rounded-lg text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary-light transition-all"
                                />
                            </div>
                        )}
                    </div>
                </Card>

                {/* Data */}
                <Card>
                    <h3 className="font-semibold text-gray-900 mb-4">Données</h3>

                    <div className="space-y-3">
                        <Button
                            onClick={handleExport}
                            variant="secondary"
                            className="w-full flex items-center justify-center gap-2"
                            disabled={exporting}
                        >
                            <Download size={18} />
                            {exporting ? 'Export en cours...' : 'Exporter en CSV'}
                        </Button>

                        <Button
                            onClick={handleReset}
                            variant="danger"
                            className="w-full flex items-center justify-center gap-2"
                        >
                            <Trash2 size={18} />
                            Réinitialiser les données
                        </Button>
                    </div>
                </Card>

                {/* About */}
                <Card>
                    <h3 className="font-semibold text-gray-900 mb-2">À propos</h3>
                    <p className="text-sm text-gray-600">Version 1.0.0</p>
                    <p className="text-xs text-gray-500 mt-2">
                        BudgetEase - Gérez votre budget simplement
                    </p>
                </Card>
            </div>
        </div>
    );
}

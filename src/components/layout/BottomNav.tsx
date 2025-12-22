import React from 'react';
import { Home, History, Target, Settings } from 'lucide-react';

interface BottomNavProps {
    activeTab: string;
    onTabChange: (tab: string) => void;
}

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
    const tabs = [
        { id: 'dashboard', label: 'Tableau de bord', icon: Home },
        { id: 'history', label: 'Historique', icon: History },
        { id: 'budgets', label: 'Budgets', icon: Target },
        { id: 'settings', label: 'Paramètres', icon: Settings },
    ];

    return (
        <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50">
            <div className="flex justify-around items-center h-16">
                {tabs.map(tab => {
                    const Icon = tab.icon;
                    const isActive = activeTab === tab.id;

                    return (
                        <button
                            key={tab.id}
                            onClick={() => onTabChange(tab.id)}
                            className={`flex flex-col items-center justify-center flex-1 h-full transition-colors ${isActive ? 'text-primary' : 'text-gray-500'
                                }`}
                        >
                            <Icon size={20} />
                            <span className="text-xs mt-1">{tab.label}</span>
                        </button>
                    );
                })}
            </div>
        </nav>
    );
}

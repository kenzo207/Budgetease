import React, { useState, useEffect } from 'react';
import { Dashboard } from './screens/Dashboard';
import { History } from './screens/History';
import { Budgets } from './screens/Budgets';
import { Settings } from './screens/Settings';
import { Onboarding } from './screens/Onboarding';
import { BottomNav } from './components/layout/BottomNav';
import { FAB } from './components/layout/FAB';
import { TransactionForm } from './components/transactions/TransactionForm';
import { db, initializeDefaultData } from './lib/db';
import { Transaction, Category } from './types';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showOnboarding, setShowOnboarding] = useState(true);
  const [showTransactionForm, setShowTransactionForm] = useState(false);
  const [editingTransaction, setEditingTransaction] = useState<Transaction | undefined>();
  const [categories, setCategories] = useState<Category[]>([]);
  const [refreshKey, setRefreshKey] = useState(0);
  const [isInitializing, setIsInitializing] = useState(true);

  useEffect(() => {
    initialize();
  }, []);

  const initialize = async () => {
    try {
      await initializeDefaultData();

      const settings = await db.settings.toArray();
      if (settings.length > 0 && settings[0].onboardingCompleted) {
        setShowOnboarding(false);
      }

      const cats = await db.categories.toArray();
      setCategories(cats);
    } catch (error) {
      console.error('Initialization error:', error);
    } finally {
      setIsInitializing(false);
    }
  };

  const handleOnboardingComplete = () => {
    setShowOnboarding(false);
  };

  const handleAddTransaction = () => {
    setEditingTransaction(undefined);
    setShowTransactionForm(true);
  };

  const handleEditTransaction = (transaction: Transaction) => {
    setEditingTransaction(transaction);
    setShowTransactionForm(true);
  };

  const handleTransactionSuccess = () => {
    setRefreshKey(prev => prev + 1);
  };

  if (isInitializing) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement...</p>
        </div>
      </div>
    );
  }

  if (showOnboarding) {
    return <Onboarding onComplete={handleOnboardingComplete} />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Screens */}
      <div key={refreshKey}>
        {activeTab === 'dashboard' && <Dashboard />}
        {activeTab === 'history' && <History onEditTransaction={handleEditTransaction} />}
        {activeTab === 'budgets' && <Budgets />}
        {activeTab === 'settings' && <Settings />}
      </div>

      {/* FAB */}
      <FAB onClick={handleAddTransaction} />

      {/* Bottom Navigation */}
      <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Transaction Form */}
      <TransactionForm
        isOpen={showTransactionForm}
        onClose={() => {
          setShowTransactionForm(false);
          setEditingTransaction(undefined);
        }}
        onSuccess={handleTransactionSuccess}
        transaction={editingTransaction}
        categories={categories}
      />
    </div>
  );
}

export default App;

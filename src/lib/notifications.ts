export async function requestNotificationPermission(): Promise<boolean> {
    if (!('Notification' in window)) {
        console.warn('Notifications not supported');
        return false;
    }

    if (Notification.permission === 'granted') {
        return true;
    }

    if (Notification.permission !== 'denied') {
        const permission = await Notification.requestPermission();
        return permission === 'granted';
    }

    return false;
}

export function scheduleDailyNotification(time: string): void {
    // Note: Web Notifications API doesn't support scheduled notifications
    // This is a limitation on web. We'll show a notification immediately as a test
    // For production, consider using a service worker with periodic sync (limited support)

    if (Notification.permission === 'granted') {
        // Store the preference
        localStorage.setItem('notificationTime', time);

        // Show a test notification
        new Notification('BudgetEase', {
            body: 'Rappel quotidien activé',
            icon: '/icons/icon-192.png',
            badge: '/icons/icon-192.png',
            tag: 'daily-reminder'
        });
    }
}

export function showNotification(title: string, body: string): void {
    if (Notification.permission === 'granted') {
        new Notification(title, {
            body,
            icon: '/icons/icon-192.png',
            badge: '/icons/icon-192.png'
        });
    }
}

// Fallback: In-app banner state
export function shouldShowInAppReminder(): boolean {
    const lastShown = localStorage.getItem('lastReminderShown');
    if (!lastShown) return true;

    const lastDate = new Date(lastShown);
    const today = new Date();

    // Show once per day
    return lastDate.toDateString() !== today.toDateString();
}

export function markReminderShown(): void {
    localStorage.setItem('lastReminderShown', new Date().toISOString());
}

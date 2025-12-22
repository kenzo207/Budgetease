/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                primary: {
                    DEFAULT: '#2563EB',
                    hover: '#1D4ED8',
                    light: '#DBEAFE',
                },
                success: {
                    DEFAULT: '#10B981',
                    light: '#D1FAE5',
                },
                warning: {
                    DEFAULT: '#F59E0B',
                    light: '#FEF3C7',
                },
                danger: {
                    DEFAULT: '#EF4444',
                    light: '#FEE2E2',
                },
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', 'sans-serif'],
            },
            boxShadow: {
                'sm': '0 1px 2px rgba(0, 0, 0, 0.05)',
                'md': '0 4px 6px rgba(0, 0, 0, 0.07)',
            },
        },
    },
    plugins: [],
}

import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#2563EB',
        secondary: '#7C3AED',
        success: '#16A34A',
        warning: '#D97706',
        danger: '#DC2626',
        background: '#F8FAFC',
        card: '#FFFFFF',
        textPrimary: '#0F172A',
        textMuted: '#64748B',
        border: '#E2E8F0',
      },
      boxShadow: {
        soft: '0 4px 20px rgba(0,0,0,0.08)',
      },
      borderRadius: {
        card: '12px',
        button: '8px',
      },
    },
  },
  plugins: [require('@tailwindcss/typography')],
};

export default config;

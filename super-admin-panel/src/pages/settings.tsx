import React from 'react';
import Layout from '../components/Layout';

const SettingsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Platform settings</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Super Admin configuration</h1>
        </div>
        <div className="grid gap-6 lg:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Company onboarding</p>
            <p className="mt-3 text-sm text-slate-600">Setup plan defaults, approval workflows, and tenant onboarding rules.</p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Billing rules</p>
            <p className="mt-3 text-sm text-slate-600">Configure payment cycles, invoice templates, and renewal notifications.</p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Security</p>
            <p className="mt-3 text-sm text-slate-600">Manage 2FA, JWT settings, and platform access controls.</p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Notifications</p>
            <p className="mt-3 text-sm text-slate-600">Set global alert routing and email channels.</p>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default SettingsPage;

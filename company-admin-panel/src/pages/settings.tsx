import React from 'react';
import Layout from '../components/Layout';

const SettingsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Settings</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Company configuration</h1>
        </div>
        <div className="grid gap-6 lg:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Company profile</p>
            <p className="mt-3 text-sm text-slate-600">Update company name, logo, address, and timezone.</p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Work hours</p>
            <p className="mt-3 text-sm text-slate-600">Configure start/end time and weekend settings.</p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Idle threshold</p>
            <p className="mt-3 text-sm text-slate-600">Set how many idle minutes count as break time.</p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Notifications</p>
            <p className="mt-3 text-sm text-slate-600">Choose email and push alert preferences.</p>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default SettingsPage;

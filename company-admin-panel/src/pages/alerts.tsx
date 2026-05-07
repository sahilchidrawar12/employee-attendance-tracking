import React from 'react';
import Layout from '../components/Layout';

const alertData = [
  { id: 'A-001', type: 'Access Violation', description: 'Employee entered restricted area without check-in.', time: 'Today, 09:12 AM', status: 'Open' },
  { id: 'A-002', type: 'Late Clock-In', description: 'Employee clocked in late at client location.', time: 'Today, 10:03 AM', status: 'Investigating' }
];

const AlertsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Alerts</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Active location and safety alerts</h1>
        </div>
        <div className="space-y-4">
          {alertData.map((alert) => (
            <div key={alert.id} className="rounded-3xl border border-slate-200 bg-slate-50 p-5">
              <div className="flex items-center justify-between">
                <p className="text-sm font-semibold text-slate-900">{alert.type}</p>
                <span className="rounded-full bg-amber-100 px-3 py-1 text-xs font-semibold text-amber-700">{alert.status}</span>
              </div>
              <p className="mt-3 text-sm text-slate-600">{alert.description}</p>
              <p className="mt-2 text-xs text-slate-500">{alert.time}</p>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  );
};

export default AlertsPage;

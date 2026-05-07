import React from 'react';
import Layout from '../components/Layout';

const alerts = [
  {
    title: 'Mock GPS Detected',
    employee: 'John D',
    company: 'ABC Corp',
    time: 'Today 10:32 AM',
    type: 'Mock GPS',
    severity: 'High'
  }
];

const AlertsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-slate-500">Platform Alerts</p>
            <h1 className="mt-2 text-2xl font-semibold text-slate-950">Alerts and incidents</h1>
          </div>
          <div className="space-x-2">
            <button className="rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700 hover:bg-slate-100">All</button>
            <button className="rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700 hover:bg-slate-100">Mock GPS</button>
            <button className="rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700 hover:bg-slate-100">Out of Zone</button>
            <button className="rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700 hover:bg-slate-100">System</button>
          </div>
        </div>

        <div className="space-y-4">
          {alerts.map((alert) => (
            <div key={alert.title} className="rounded-3xl border border-slate-200 bg-slate-50 p-5">
              <p className="text-base font-semibold text-slate-950">🔴 {alert.title}</p>
              <p className="mt-2 text-sm text-slate-600">Employee: {alert.employee} | Company: {alert.company}</p>
              <p className="mt-1 text-sm text-slate-500">Time: {alert.time}</p>
              <button className="mt-4 rounded-2xl bg-sky-600 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-700">View Details</button>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  );
};

export default AlertsPage;

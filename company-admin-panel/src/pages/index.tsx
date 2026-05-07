import React from 'react';
import { AlertTriangle, BarChart3, MapPin, Monitor, Users } from 'lucide-react';

const stats = [
  { title: 'Total Employees', value: '85', label: 'Employees', color: 'bg-sky-100 text-sky-700', icon: Users },
  { title: 'Checked In Today', value: '72', label: 'Checked in', color: 'bg-emerald-100 text-emerald-700', icon: BarChart3 },
  { title: 'Out of Zone Now', value: '3', label: 'Out of zone', color: 'bg-amber-100 text-amber-700', icon: AlertTriangle },
  { title: 'Pending Approvals', value: '5', label: 'Approvals', color: 'bg-violet-100 text-violet-700', icon: Monitor },
  { title: 'PCs Online', value: '61', label: 'Online PCs', color: 'bg-slate-100 text-slate-700', icon: Monitor }
];

import Layout from '../components/Layout';

const HomePage = () => {
  return (
    <Layout>
      <section className="mb-8 flex items-center justify-between gap-4">
        <div>
          <p className="text-sm uppercase tracking-[0.2em] text-slate-500">Company Admin Dashboard</p>
          <h1 className="mt-3 text-3xl font-semibold text-slate-950">Live attendance overview</h1>
        </div>
      </section>

      <section className="grid gap-4 xl:grid-cols-5">
        {stats.map((stat) => (
          <article key={stat.title} className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
            <div className="flex items-center gap-4">
              <span className={`inline-flex h-11 w-11 items-center justify-center rounded-2xl ${stat.color}`}>
                <stat.icon className="h-5 w-5" />
              </span>
              <div>
                <p className="text-sm font-medium text-slate-500">{stat.title}</p>
                <p className="mt-2 text-2xl font-semibold text-slate-950">{stat.value}</p>
              </div>
            </div>
          </article>
        ))}
      </section>

      <section className="mt-8 grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">Attendance trend</p>
              <h2 className="text-xl font-semibold text-slate-950">Daily attendance last 30 days</h2>
            </div>
          </div>
          <div className="h-72 rounded-[24px] bg-slate-100"></div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">Live location</p>
              <h2 className="text-xl font-semibold text-slate-950">Mini map</h2>
            </div>
          </div>
          <div className="h-72 rounded-[24px] bg-slate-100"></div>
        </div>
      </section>

      <section className="mt-8 grid gap-6 xl:grid-cols-2">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
          <div className="mb-6">
            <p className="text-sm font-medium text-slate-500">Recent check-ins</p>
            <h2 className="text-xl font-semibold text-slate-950">Latest presence activity</h2>
          </div>
          <div className="h-72 rounded-[24px] bg-slate-100"></div>
        </div>
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
          <div className="mb-6">
            <p className="text-sm font-medium text-slate-500">Recent alerts</p>
            <h2 className="text-xl font-semibold text-slate-950">Actionable incidents</h2>
          </div>
          <div className="space-y-3">
            <div className="rounded-3xl bg-slate-50 p-4">
              <p className="text-sm font-semibold text-slate-900">Mock GPS detected</p>
              <p className="text-sm text-slate-600">John D is outside allowed zone</p>
            </div>
          </div>
        </div>
      </section>
    </Layout>
  );
};

export default HomePage;

import React from 'react';
import { ArrowRight, Briefcase, CreditCard, Shield, Sparkles, Users } from 'lucide-react';

const dashboardMetrics = [
  {
    title: 'Total Companies',
    value: '48',
    detail: '+3 this week',
    icon: Briefcase,
    color: 'bg-sky-100 text-sky-700'
  },
  {
    title: 'Active Companies',
    value: '42',
    detail: '87% active',
    icon: Sparkles,
    color: 'bg-violet-100 text-violet-700'
  },
  {
    title: 'Total Users',
    value: '1,240',
    detail: 'across all',
    icon: Users,
    color: 'bg-emerald-100 text-emerald-700'
  },
  {
    title: 'Alerts Today',
    value: '7',
    detail: 'view all →',
    icon: Shield,
    color: 'bg-orange-100 text-orange-700'
  }
];

const companies = [
  {
    name: 'ABC Corporation',
    owner: 'Rahul Sharma',
    plan: 'Pro',
    users: 45,
    status: 'Active',
    joined: '2 days ago'
  }
];

import Layout from '../components/Layout';

const HomePage = () => {
  return (
    <Layout>
      <section className="mb-8">
        <div className="flex items-center justify-between gap-4">
          <div>
            <p className="text-sm uppercase tracking-[0.2em] text-slate-500">Super Admin Dashboard</p>
            <h1 className="mt-3 text-3xl font-semibold text-slate-950">Platform overview</h1>
          </div>
          <button className="inline-flex items-center rounded-full bg-sky-600 px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-sky-200/50 transition hover:bg-sky-700">
            Create company
            <ArrowRight className="ml-2 h-4 w-4" />
          </button>
        </div>
      </section>

      <section className="grid gap-4 xl:grid-cols-4">
        {dashboardMetrics.map((metric) => (
          <article key={metric.title} className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
            <div className="flex items-center gap-3">
              <span className={`inline-flex h-11 w-11 items-center justify-center rounded-2xl ${metric.color}`}>
                <metric.icon className="h-5 w-5" />
              </span>
              <div>
                <p className="text-sm font-medium text-slate-500">{metric.title}</p>
                <p className="mt-2 text-2xl font-semibold text-slate-950">{metric.value}</p>
              </div>
            </div>
            <p className="mt-4 text-sm text-slate-500">{metric.detail}</p>
          </article>
        ))}
      </section>

      <section className="mt-8 grid gap-6 xl:grid-cols-[1.4fr_0.6fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">Company growth</p>
              <h2 className="text-xl font-semibold text-slate-950">New companies joined per month</h2>
            </div>
          </div>
          <div className="h-72 rounded-[24px] bg-slate-100"></div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">Plan distribution</p>
              <h2 className="text-xl font-semibold text-slate-950">Starter / Pro / Enterprise</h2>
            </div>
          </div>
          <div className="h-72 rounded-[24px] bg-slate-100"></div>
        </div>
      </section>

      <section className="mt-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)]">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-slate-500">Recent companies</p>
            <h2 className="text-xl font-semibold text-slate-950">Latest tenant activity</h2>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm text-slate-600">
            <thead>
              <tr>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Company Name</th>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Owner</th>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Plan</th>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Users</th>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Status</th>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Joined</th>
                <th className="pb-4 text-sm font-semibold uppercase tracking-[0.15em] text-slate-500">Actions</th>
              </tr>
            </thead>
            <tbody>
              {companies.map((company) => (
                <tr key={company.name} className="border-t border-slate-200 bg-slate-50">
                  <td className="py-4 pr-6 text-sm font-medium text-slate-900">{company.name}</td>
                  <td className="py-4 pr-6 text-sm text-slate-600">{company.owner}</td>
                  <td className="py-4 pr-6 text-sm text-slate-600">{company.plan}</td>
                  <td className="py-4 pr-6 text-sm text-slate-600">{company.users}</td>
                  <td className="py-4 pr-6 text-sm text-emerald-700">{company.status}</td>
                  <td className="py-4 pr-6 text-sm text-slate-600">{company.joined}</td>
                  <td className="py-4 pr-6 text-sm text-sky-600">Edit / Block</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </Layout>
  );
};

export default HomePage;

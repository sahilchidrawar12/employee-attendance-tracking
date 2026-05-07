import React from 'react';
import Layout from '../components/Layout';

const plans = [
  { name: 'Starter', price: '₹999/month', seats: '25 users', description: 'Mobile only', perks: ['Basic report'] },
  { name: 'Professional', price: '₹2499/month', seats: '100 users', description: 'Mobile + PC', perks: ['Approvals', 'Advanced reports'] },
  { name: 'Enterprise', price: '₹4999/month', seats: 'Unlimited', description: 'All + custom', perks: ['Priority support', 'White label'] }
];

const PlansPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Plans & Billing</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Subscription plans</h1>
        </div>

        <div className="grid gap-4 lg:grid-cols-3">
          {plans.map((plan) => (
            <div key={plan.name} className="rounded-3xl border border-slate-200 bg-slate-50 p-6 shadow-soft">
              <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">{plan.name}</p>
              <p className="mt-4 text-3xl font-semibold text-slate-950">{plan.price}</p>
              <p className="mt-2 text-sm text-slate-600">{plan.seats}</p>
              <p className="mt-4 text-sm text-slate-700">{plan.description}</p>
              <ul className="mt-4 space-y-2 text-sm text-slate-600">
                {plan.perks.map((perk) => (
                  <li key={perk}>• {perk}</li>
                ))}
              </ul>
              <button className="mt-6 w-full rounded-2xl bg-sky-600 px-4 py-3 text-sm font-semibold text-white hover:bg-sky-700">
                Edit Plan
              </button>
            </div>
          ))}
        </div>

        <div className="mt-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <p className="text-lg font-semibold text-slate-950">Billing history</p>
          <div className="mt-4 overflow-x-auto">
            <table className="min-w-full text-left text-sm text-slate-600">
              <thead>
                <tr>
                  <th className="pb-4 font-semibold text-slate-500">Company</th>
                  <th className="pb-4 font-semibold text-slate-500">Plan</th>
                  <th className="pb-4 font-semibold text-slate-500">Amount</th>
                  <th className="pb-4 font-semibold text-slate-500">Due Date</th>
                  <th className="pb-4 font-semibold text-slate-500">Status</th>
                  <th className="pb-4 font-semibold text-slate-500">Invoice</th>
                </tr>
              </thead>
              <tbody>
                <tr className="border-t border-slate-200">
                  <td className="py-4">ABC Corporation</td>
                  <td className="py-4">Professional</td>
                  <td className="py-4">₹2,499</td>
                  <td className="py-4">01 Jun 2026</td>
                  <td className="py-4 text-emerald-700">Paid</td>
                  <td className="py-4 text-sky-600">Download</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default PlansPage;

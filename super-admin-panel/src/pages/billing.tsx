import React from 'react';
import Layout from '../components/Layout';

const invoices = [
  { company: 'ABC Corporation', plan: 'Professional', amount: '₹2,499', dueDate: '01 Jun 2026', status: 'Paid', invoiceUrl: '#' }
];

const BillingPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Billing</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Invoice and payment history</h1>
        </div>
        <div className="overflow-x-auto rounded-[32px] border border-slate-200 bg-slate-50 p-6">
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
              {invoices.map((invoice) => (
                <tr key={invoice.company} className="border-t border-slate-200">
                  <td className="py-4 font-medium text-slate-900">{invoice.company}</td>
                  <td className="py-4">{invoice.plan}</td>
                  <td className="py-4">{invoice.amount}</td>
                  <td className="py-4">{invoice.dueDate}</td>
                  <td className="py-4 text-emerald-700">{invoice.status}</td>
                  <td className="py-4 text-sky-600"><a href={invoice.invoiceUrl}>Download</a></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default BillingPage;

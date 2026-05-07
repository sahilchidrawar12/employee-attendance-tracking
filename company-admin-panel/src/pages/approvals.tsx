import React from 'react';
import Layout from '../components/Layout';

const approvals = [
  {
    employee: 'Ravi Kumar',
    time: '10:45 AM',
    location: 'Kolhapur Client XYZ',
    reason: 'Client meeting',
    status: 'pending'
  }
];

const ApprovalsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Approvals</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Pending location requests</h1>
        </div>

        <div className="space-y-4">
          {approvals.map((request) => (
            <div key={request.employee} className="rounded-3xl border border-slate-200 bg-slate-50 p-5">
              <p className="text-base font-semibold text-slate-950">📍 Location Request</p>
              <p className="mt-2 text-sm text-slate-600">Employee: {request.employee} | Time: {request.time}</p>
              <p className="mt-1 text-sm text-slate-600">Location: {request.location}</p>
              <p className="mt-1 text-sm text-slate-600">Reason: {request.reason}</p>
              <div className="mt-4 flex gap-3">
                <button className="rounded-2xl bg-emerald-600 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-700">Approve</button>
                <button className="rounded-2xl bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700">Reject</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  );
};

export default ApprovalsPage;

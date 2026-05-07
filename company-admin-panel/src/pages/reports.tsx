import React from 'react';
import Layout from '../components/Layout';

const ReportsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6">
          <p className="text-sm font-medium text-slate-500">Reports</p>
          <h1 className="mt-2 text-2xl font-semibold text-slate-950">Attendance and productivity analytics</h1>
        </div>
        <div className="grid gap-6 lg:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Attendance report</p>
            <div className="mt-6 h-52 rounded-[24px] bg-white" />
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6">
            <p className="text-sm font-semibold text-slate-800">Productivity report</p>
            <div className="mt-6 h-52 rounded-[24px] bg-white" />
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default ReportsPage;

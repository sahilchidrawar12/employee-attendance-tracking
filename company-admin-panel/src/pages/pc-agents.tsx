import React from 'react';
import Layout from '../components/Layout';

const agents = [
  { employee: 'John D', pcName: 'PC-JOHN', hardwareId: 'A1B2C3D4', mappedOn: '12 Jan', lastSync: '2 min ago', status: 'Online' }
];

const PcAgentsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-sm font-medium text-slate-500">PC Agents</p>
            <h1 className="mt-2 text-2xl font-semibold text-slate-950">Agent registration and mapping</h1>
          </div>
          <button className="rounded-2xl bg-sky-600 px-5 py-3 text-sm font-semibold text-white hover:bg-sky-700">+ Generate Token</button>
        </div>

        <div className="overflow-x-auto rounded-3xl border border-slate-200 bg-slate-50 p-4">
          <table className="min-w-full text-left text-sm text-slate-600">
            <thead>
              <tr>
                <th className="pb-4 font-semibold text-slate-500">Employee</th>
                <th className="pb-4 font-semibold text-slate-500">PC Name</th>
                <th className="pb-4 font-semibold text-slate-500">Hardware ID</th>
                <th className="pb-4 font-semibold text-slate-500">Mapped On</th>
                <th className="pb-4 font-semibold text-slate-500">Last Sync</th>
                <th className="pb-4 font-semibold text-slate-500">Status</th>
              </tr>
            </thead>
            <tbody>
              {agents.map((agent) => (
                <tr key={agent.employee} className="border-t border-slate-200">
                  <td className="py-4 font-medium text-slate-900">{agent.employee}</td>
                  <td className="py-4">{agent.pcName}</td>
                  <td className="py-4">{agent.hardwareId}</td>
                  <td className="py-4">{agent.mappedOn}</td>
                  <td className="py-4">{agent.lastSync}</td>
                  <td className="py-4 text-emerald-700">{agent.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default PcAgentsPage;

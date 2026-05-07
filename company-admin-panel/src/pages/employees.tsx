import React from 'react';
import Layout from '../components/Layout';

const employees = [
  { name: 'John Doe', dept: 'Sales', phone: '+919876543210', pcMapped: true, pcName: 'PC-JOHN', status: 'Active' }
];

const EmployeesPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-sm font-medium text-slate-500">Employees</p>
            <h1 className="mt-2 text-2xl font-semibold text-slate-950">Team management</h1>
          </div>
          <button className="rounded-2xl bg-sky-600 px-5 py-3 text-sm font-semibold text-white hover:bg-sky-700">+ Add Employee</button>
        </div>

        <div className="rounded-[32px] border border-slate-200 bg-slate-50 p-5">
          <div className="grid gap-4 sm:grid-cols-3">
            <input className="rounded-2xl border border-slate-200 bg-white px-4 py-3" placeholder="Search employees" />
            <select className="rounded-2xl border border-slate-200 bg-white px-4 py-3">
              <option>All departments</option>
              <option>Sales</option>
              <option>Operations</option>
            </select>
            <button className="rounded-2xl bg-white px-4 py-3 text-sm text-slate-700 shadow-sm hover:bg-slate-100">Filter</button>
          </div>
        </div>

        <div className="mt-6 overflow-x-auto rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <table className="min-w-full text-left text-sm text-slate-600">
            <thead>
              <tr>
                <th className="pb-4 font-semibold text-slate-500">Name</th>
                <th className="pb-4 font-semibold text-slate-500">Dept</th>
                <th className="pb-4 font-semibold text-slate-500">Mobile</th>
                <th className="pb-4 font-semibold text-slate-500">PC Mapped</th>
                <th className="pb-4 font-semibold text-slate-500">Status</th>
                <th className="pb-4 font-semibold text-slate-500">Actions</th>
              </tr>
            </thead>
            <tbody>
              {employees.map((employee) => (
                <tr key={employee.name} className="border-t border-slate-200">
                  <td className="py-4 font-medium text-slate-900">{employee.name}</td>
                  <td className="py-4">{employee.dept}</td>
                  <td className="py-4">{employee.phone}</td>
                  <td className="py-4">{employee.pcMapped ? employee.pcName : 'No'}</td>
                  <td className="py-4 text-emerald-700">{employee.status}</td>
                  <td className="py-4 space-x-2">
                    <button className="rounded-2xl bg-slate-100 px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-200">Edit</button>
                    <button className="rounded-2xl bg-slate-100 px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-200">View</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default EmployeesPage;

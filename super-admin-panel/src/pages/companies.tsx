import React from 'react';
import Layout from '../components/Layout';

const companies = [
  {
    name: 'ABC Corporation',
    owner: 'Rahul Sharma',
    plan: 'Professional',
    users: 45,
    locations: 12,
    status: 'Active',
    joined: '12 Jan 2025'
  }
];

const CompaniesPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-sm font-medium text-slate-500">Companies</p>
            <h1 className="mt-2 text-2xl font-semibold text-slate-950">Tenant management</h1>
          </div>
          <button className="rounded-2xl bg-sky-600 px-5 py-3 text-sm font-semibold text-white hover:bg-sky-700">
            + Add Company
          </button>
        </div>

        <div className="rounded-[32px] border border-slate-200 bg-slate-50 p-5">
          <div className="grid gap-4 sm:grid-cols-3">
            <input className="rounded-2xl border border-slate-200 bg-white px-4 py-3" placeholder="Search companies" />
            <select className="rounded-2xl border border-slate-200 bg-white px-4 py-3">
              <option>All plans</option>
              <option>Starter</option>
              <option>Professional</option>
              <option>Enterprise</option>
            </select>
            <select className="rounded-2xl border border-slate-200 bg-white px-4 py-3">
              <option>All statuses</option>
              <option>Active</option>
              <option>Inactive</option>
              <option>Suspended</option>
            </select>
          </div>
        </div>

        <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {companies.map((company) => (
            <div key={company.name} className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <div className="mb-4 flex items-center justify-between">
                <div>
                  <p className="text-lg font-semibold text-slate-950">{company.name}</p>
                  <p className="text-sm text-slate-500">Owner: {company.owner}</p>
                </div>
                <span className="rounded-full bg-emerald-100 px-3 py-1 text-sm text-emerald-700">{company.status}</span>
              </div>
              <p className="text-sm text-slate-600">Plan: {company.plan}</p>
              <p className="mt-2 text-sm text-slate-600">Users: {company.users}/100</p>
              <p className="mt-1 text-sm text-slate-600">Locations: {company.locations}</p>
              <p className="mt-1 text-sm text-slate-600">Joined: {company.joined}</p>
              <div className="mt-6 flex flex-wrap gap-2">
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-slate-700 hover:bg-slate-100">View</button>
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-slate-700 hover:bg-slate-100">Edit</button>
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-warning hover:bg-amber-100">Suspend</button>
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-danger hover:bg-red-100">Delete</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  );
};

export default CompaniesPage;

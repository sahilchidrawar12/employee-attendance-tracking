import React from 'react';
import Layout from '../components/Layout';

const locations = [
  { name: 'Pune Head Office', type: 'Office', address: 'Baner Road, Pune', radius: 100, employees: 34, status: 'Active' }
];

const LocationsPage = () => {
  return (
    <Layout>
      <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-sm font-medium text-slate-500">Locations</p>
            <h1 className="mt-2 text-2xl font-semibold text-slate-950">Geofence master panel</h1>
          </div>
          <button className="rounded-2xl bg-sky-600 px-5 py-3 text-sm font-semibold text-white hover:bg-sky-700">+ Add Location</button>
        </div>

        <div className="grid gap-4 lg:grid-cols-3">
          {locations.map((location) => (
            <div key={location.name} className="rounded-3xl border border-slate-200 bg-slate-50 p-6 shadow-soft">
              <div className="mb-3 flex items-center justify-between">
                <div>
                  <p className="text-lg font-semibold text-slate-950">{location.name}</p>
                  <p className="text-sm text-slate-600">Type: {location.type}</p>
                </div>
                <span className="rounded-full bg-emerald-100 px-3 py-1 text-sm text-emerald-700">{location.status}</span>
              </div>
              <p className="text-sm text-slate-600">Address: {location.address}</p>
              <p className="mt-2 text-sm text-slate-600">Radius: {location.radius} meters</p>
              <p className="mt-2 text-sm text-slate-600">Employees Assigned: {location.employees}</p>
              <div className="mt-6 flex flex-wrap gap-2">
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-slate-700 hover:bg-slate-100">View on Map</button>
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-slate-700 hover:bg-slate-100">Edit</button>
                <button className="rounded-2xl border border-slate-200 px-4 py-2 text-sm text-amber-700 hover:bg-amber-100">Deactivate</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  );
};

export default LocationsPage;

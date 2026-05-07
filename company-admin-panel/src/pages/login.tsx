import React from 'react';
import { useRouter } from 'next/router';

const LoginPage = () => {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-slate-50 py-24 px-6">
      <div className="mx-auto max-w-md rounded-[32px] border border-slate-200 bg-white p-10 shadow-soft">
        <div className="mb-8 text-center">
          <p className="text-sm uppercase tracking-[0.24em] text-slate-500">Company Admin</p>
          <h1 className="mt-4 text-3xl font-semibold text-slate-950">Login to manage operations</h1>
        </div>
        <div className="space-y-5">
          <label className="block text-sm font-medium text-slate-700">Email</label>
          <input className="w-full rounded-3xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-900" type="email" placeholder="office@company.com" />
          <label className="block text-sm font-medium text-slate-700">Password</label>
          <input className="w-full rounded-3xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-900" type="password" placeholder="••••••••" />
          <button
            type="button"
            onClick={() => router.push('/')}
            className="w-full rounded-3xl bg-sky-600 px-4 py-3 text-sm font-semibold text-white transition hover:bg-sky-700"
          >
            Sign in
          </button>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;

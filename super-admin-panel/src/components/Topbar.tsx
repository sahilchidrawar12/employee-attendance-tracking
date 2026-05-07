import { Bell, UserCircle2 } from 'lucide-react';

const Topbar = () => {
  return (
    <div className="flex items-center justify-between rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
      <div>
        <p className="text-sm font-medium text-slate-500">Platform Owner</p>
        <h1 className="mt-2 text-2xl font-semibold text-slate-950">Super Admin Workspace</h1>
      </div>
      <div className="flex items-center gap-4">
        <button className="inline-flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600 hover:bg-slate-200">
          <Bell className="h-5 w-5" />
        </button>
        <button className="inline-flex items-center gap-3 rounded-2xl bg-slate-100 px-4 py-3 text-sm font-medium text-slate-900 hover:bg-slate-200">
          <UserCircle2 className="h-5 w-5" />
          Super Admin
        </button>
      </div>
    </div>
  );
};

export default Topbar;

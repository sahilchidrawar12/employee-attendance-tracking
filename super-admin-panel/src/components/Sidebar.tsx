import Link from 'next/link';
import { Building2, CreditCard, LayoutDashboard, Shield, Bell, Settings, Subscription } from 'lucide-react';

const navItems = [
  { label: 'Dashboard', href: '/', icon: LayoutDashboard },
  { label: 'Companies', href: '/companies', icon: Building2 },
  { label: 'Subscriptions', href: '/subscriptions', icon: Subscription },
  { label: 'Plans', href: '/plans', icon: CreditCard },
  { label: 'Billing', href: '/billing', icon: Shield },
  { label: 'Alerts', href: '/alerts', icon: Bell },
  { label: 'Settings', href: '/settings', icon: Settings }
];

const Sidebar = () => {
  return (
    <aside className="w-72 rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
      <div className="mb-10">
        <div className="mb-4 rounded-3xl bg-sky-50 p-4 text-slate-900">
          <p className="text-sm font-semibold">Attendance Tracker</p>
          <p className="text-xs text-slate-500">Platform owner console</p>
        </div>
      </div>
      <nav className="space-y-2">
        {navItems.map((item) => (
          <Link key={item.href} href={item.href} className="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-100">
            <item.icon className="h-4 w-4" />
            {item.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;

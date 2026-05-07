import Link from 'next/link';
import { AlertCircle, BarChart3, MapPin, Users, Settings, ServerCog } from 'lucide-react';

const items = [
  { label: 'Dashboard', href: '/', icon: BarChart3 },
  { label: 'Live Map', href: '/live-map', icon: MapPin },
  { label: 'Employees', href: '/employees', icon: Users },
  { label: 'Locations', href: '/locations', icon: ServerCog },
  { label: 'Approvals', href: '/approvals', icon: AlertCircle },
  { label: 'PC Agents', href: '/pc-agents', icon: ServerCog },
  { label: 'Reports', href: '/reports', icon: BarChart3 },
  { label: 'Alerts', href: '/alerts', icon: AlertCircle },
  { label: 'Settings', href: '/settings', icon: Settings }
];

const Sidebar = () => {
  return (
    <aside className="w-72 rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
      <div className="mb-10">
        <p className="text-sm font-semibold text-slate-500">Company Admin</p>
        <h2 className="mt-2 text-xl font-semibold text-slate-950">Acme Foods</h2>
      </div>
      <nav className="space-y-2">
        {items.map((item) => (
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

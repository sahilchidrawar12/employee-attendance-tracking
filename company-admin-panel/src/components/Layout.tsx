import React from 'react';
import Sidebar from './Sidebar';
import Topbar from './Topbar';

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <div className="min-h-screen bg-slate-50">
      <div className="mx-auto flex max-w-[1600px] gap-6 px-6 py-6">
        <Sidebar />
        <div className="flex-1 space-y-6">
          <Topbar />
          <div>{children}</div>
        </div>
      </div>
    </div>
  );
};

export default Layout;

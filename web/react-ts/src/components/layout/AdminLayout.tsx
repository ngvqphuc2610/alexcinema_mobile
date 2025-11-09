import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Topbar from './Topbar';

const AdminLayout = () => {
  const [sidebarVisible, setSidebarVisible] = useState(true);

  const toggleSidebar = () => setSidebarVisible((prev) => !prev);

  return (
    <div className="layout">
      <div className={`layout__sidebar ${sidebarVisible ? '' : 'layout__sidebar--hidden'}`}>
        <Sidebar />
      </div>
      <div className="layout__main">
        <Topbar onToggleSidebar={toggleSidebar} />
        <main className="layout__content">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;


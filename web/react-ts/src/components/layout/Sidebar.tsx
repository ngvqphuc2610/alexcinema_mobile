import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Film,
  Clock,
  Ticket,
  PercentCircle,
} from 'lucide-react';
import clsx from 'clsx';

const navItems = [
  { to: '/dashboard', label: 'Tong quan', icon: LayoutDashboard },
  { to: '/users', label: 'Nguoi dung', icon: Users },
  { to: '/movies', label: 'Phim', icon: Film },
  { to: '/showtimes', label: 'Suat chieu', icon: Clock },
  { to: '/bookings', label: 'Dat ve', icon: Ticket },
  { to: '/promotions', label: 'Khuyen mai', icon: PercentCircle },
];

const Sidebar = () => (
  <aside className="sidebar">
    <div className="sidebar__brand">
      <span className="sidebar__logo">AC</span>
      <div>
        <p className="sidebar__title">Alex Cinema</p>
        <p className="sidebar__subtitle">Admin Dashboard</p>
      </div>
    </div>
    <nav className="sidebar__nav">
      {navItems.map((item) => {
        const Icon = item.icon;
        return (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              clsx('sidebar__link', {
                'sidebar__link--active': isActive,
              })
            }
          >
            <Icon size={18} />
            <span>{item.label}</span>
          </NavLink>
        );
      })}
    </nav>
  </aside>
);

export default Sidebar;


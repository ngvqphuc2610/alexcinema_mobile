import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Film,
  Clock,
  Ticket,
  PercentCircle,
  Building2,
  DoorOpen,
  Armchair,
  Sparkles,
  UserPlus2,
  Gem,
  UserCog,
  Mail,
} from 'lucide-react';
import clsx from 'clsx';

const navItems = [
  { to: '/dashboard', label: 'Tong quan', icon: LayoutDashboard },
  { to: '/users', label: 'Nguoi dung', icon: Users },
  { to: '/movies', label: 'Phim', icon: Film },
  { to: '/showtimes', label: 'Suat chieu', icon: Clock },
  { to: '/bookings', label: 'Dat ve', icon: Ticket },
  { to: '/promotions', label: 'Khuyen mai', icon: PercentCircle },
  { to: '/cinemas', label: 'Rap', icon: Building2 },
  { to: '/screens', label: 'Phong chieu', icon: DoorOpen },
  { to: '/products', label: 'San pham', icon: Ticket },
  { to: '/seats', label: 'Ghe', icon: Armchair },
  { to: '/entertainment', label: 'Su kien', icon: Sparkles },
  { to: '/members', label: 'Thanh vien', icon: UserPlus2 },
  { to: '/memberships', label: 'Membership', icon: Gem },
  { to: '/staff', label: 'Nhan vien', icon: UserCog },
  { to: '/contacts', label: 'Lien he', icon: Mail },
  { to: '/product-types', label: 'Loai san pham', icon: Ticket },

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

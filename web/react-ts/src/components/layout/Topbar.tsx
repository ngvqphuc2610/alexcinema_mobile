import { Menu, LogOut, UserCircle2 } from 'lucide-react';
import Button from '../common/Button';
import { useAuth } from '../../hooks/useAuth';

export interface TopbarProps {
  onToggleSidebar?: () => void;
}

const Topbar = ({ onToggleSidebar }: TopbarProps) => {
  const { user, logout } = useAuth();

  return (
    <header className="topbar">
      <div className="topbar__left">
        <button type="button" className="topbar__toggle" onClick={onToggleSidebar}>
          <Menu size={20} />
        </button>
        <h1 className="topbar__title">Bang dieu khien</h1>
      </div>
      <div className="topbar__right">
        <div className="topbar__user">
          <UserCircle2 size={28} />
          <div>
            <p className="topbar__user-name">{user?.full_name ?? 'Admin'}</p>
            <p className="topbar__user-role">{user?.role}</p>
          </div>
        </div>
        <Button variant="ghost" onClick={logout} leftIcon={<LogOut size={16} />}>
          Dang xuat
        </Button>
      </div>
    </header>
  );
};

export default Topbar;


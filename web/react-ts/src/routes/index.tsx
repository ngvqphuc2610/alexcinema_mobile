import { Navigate, Outlet, createBrowserRouter } from 'react-router-dom';
import AdminLayout from '../components/layout/AdminLayout';
import LoadingOverlay from '../components/common/LoadingOverlay';
import { useAuth } from '../hooks/useAuth';
import LoginPage from '../pages/LoginPage';
import DashboardPage from '../pages/dashboard/DashboardPage';
import UsersPage from '../pages/users/UsersPage';
import MoviesPage from '../pages/movies/MoviesPage';
import ShowtimesPage from '../pages/showtimes/ShowtimesPage';
import BookingsPage from '../pages/bookings/BookingsPage';
import PromotionsPage from '../pages/promotions/PromotionsPage';

const ProtectedRoute = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <LoadingOverlay fullscreen message="Dang kiem tra phien dang nhap..." />;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
};

export const router = createBrowserRouter([
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/',
    element: <ProtectedRoute />,
    children: [
      {
        element: <AdminLayout />,
        children: [
          { index: true, element: <Navigate to="/dashboard" replace /> },
          { path: 'dashboard', element: <DashboardPage /> },
          { path: 'users', element: <UsersPage /> },
          { path: 'movies', element: <MoviesPage /> },
          { path: 'showtimes', element: <ShowtimesPage /> },
          { path: 'bookings', element: <BookingsPage /> },
          { path: 'promotions', element: <PromotionsPage /> },
        ],
      },
    ],
  },
  {
    path: '*',
    element: <Navigate to="/dashboard" replace />,
  },
]);


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
import CinemasPage from '../pages/cinemas/CinemasPage';
import ScreensPage from '../pages/screen/ScreensPage';
import SeatsPage from '../pages/seats/SeatsPage';
import EntertainmentPage from '../pages/entertainment/EntertainmentPage';
import MembersPage from '../pages/members/MembersPage';
import MembershipsPage from '../pages/memberships/MembershipsPage';
import StaffsPage from '../pages/staffs/StaffsPage';
import ContactsPage from '../pages/contacts/ContactsPage';
import ProductsPage from '../pages/products/ProductsPage';
import ProductTypePage from '../pages/product_types/ProductTypePage';
import PaymentMethodsPage from '../pages/payment_methods/PaymentMethodsPage';
import PaymentsPage from '../pages/payments/PaymentsPage';

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
          { path: 'cinemas', element: <CinemasPage /> },
          { path: 'screens', element: <ScreensPage /> },
          { path: 'products', element: <ProductsPage /> },
          { path: 'seats', element: <SeatsPage /> },
          { path: 'entertainment', element: <EntertainmentPage /> },
          { path: 'members', element: <MembersPage /> },
          { path: 'memberships', element: <MembershipsPage /> },
          { path: 'staff', element: <StaffsPage /> },
          { path: 'contacts', element: <ContactsPage /> },
          { path: 'product-types', element: <ProductTypePage /> },
          { path: 'payment-methods', element: <PaymentMethodsPage /> },
          { path: 'payments', element: <PaymentsPage /> },
        ],
      },
    ],
  },
  {
    path: '*',
    element: <Navigate to="/dashboard" replace />,
  },
]);

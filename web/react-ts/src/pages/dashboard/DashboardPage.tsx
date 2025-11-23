import { useQuery } from '@tanstack/react-query';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import EmptyState from '../../components/common/EmptyState';
import ErrorState from '../../components/common/ErrorState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import Badge from '../../components/common/Badge';
import StatusDot from '../../components/common/StatusDot';
import { formatCurrency, formatDateTime, formatStatus, formatTime } from '../../utils/format';
import { fetchUsers } from '../../api/users';
import { fetchMovies } from '../../api/movies';
import { fetchShowtimes } from '../../api/showtimes';
import { fetchBookings } from '../../api/bookings';
import { fetchPromotions } from '../../api/promotions';


type DashboardSummary = {
  users: number;
  movies: number;
  showtimes: number;
  bookings: number;
  promotions: number;
};

const DashboardPage = () => {
  const summaryQuery = useQuery<DashboardSummary>({
    queryKey: ['dashboard', 'summary'],
    queryFn: async () => {
      const [usersRes, moviesRes, showtimesRes, bookingsRes, promotionsRes] = await Promise.all([
        fetchUsers({ limit: 1 }),
        fetchMovies({ limit: 1 }),
        fetchShowtimes({ limit: 1 }),
        fetchBookings({ limit: 1 }),
        fetchPromotions({ limit: 1 }),
      ]);

      return {
        users: usersRes.meta.total,
        movies: moviesRes.meta.total,
        showtimes: showtimesRes.meta.total,
        bookings: bookingsRes.meta.total,
        promotions: promotionsRes.meta.total,
      };
    },
    staleTime: 60 * 1000,
  });

  const latestBookingsQuery = useQuery({
    queryKey: ['dashboard', 'latestBookings'],
    queryFn: () => fetchBookings({ limit: 5 }),
    staleTime: 30 * 1000,
  });

  const upcomingShowtimesQuery = useQuery({
    queryKey: ['dashboard', 'upcomingShowtimes'],
    queryFn: () => fetchShowtimes({ limit: 5 }),
    staleTime: 30 * 1000,
  });

  if (summaryQuery.isLoading) {
    return <LoadingOverlay fullscreen message="Đang tải dữ liệu tổng quan..." />;
  }

  if (summaryQuery.isError || !summaryQuery.data) {
    return (
      <ErrorState
        onRetry={() => summaryQuery.refetch()}
        description="Không tải được thống kê. Vui lòng kiểm tra kết nối và thử lại."
      />
    );
  }

  const { users, movies, showtimes, bookings, promotions } = summaryQuery.data;

  return (
    <div className="dashboard">
      {/* Header */}
      <header className="dashboard__header">
        <div className="dashboard__header-main">
          <h1 className="dashboard__title">Tổng quan hệ thống</h1>
          <p className="dashboard__subtitle">
            Theo dõi nhanh tình hình người dùng, phim, suất chiếu và đơn đặt vé trong rạp.
          </p>
        </div>
        <div className="dashboard__header-actions">
          <button
            type="button"
            className="btn btn--primary"
            onClick={() => window.location.assign('/showtimes/new')}
          >
            + Tạo suất chiếu mới
          </button>
        </div>
      </header>

      {/* Stat cards */}
      <section className="dashboard__stats">
        <Card>
          <div className="stat-card">
            <div className="stat-card__header">
              <span className="stat-card__icon">👤</span>
              <span className="stat-card__label">Người dùng</span>
            </div>
            <p className="stat-card__value">{users}</p>
            <p className="stat-card__description">Tổng số tài khoản trong hệ thống</p>
          </div>
        </Card>

        <Card>
          <div className="stat-card">
            <div className="stat-card__header">
              <span className="stat-card__icon">🎬</span>
              <span className="stat-card__label">Phim</span>
            </div>
            <p className="stat-card__value">{movies}</p>
            <p className="stat-card__description">Phim đang được quản lý</p>
          </div>
        </Card>

        <Card>
          <div className="stat-card">
            <div className="stat-card__header">
              <span className="stat-card__icon">🕒</span>
              <span className="stat-card__label">Suất chiếu</span>
            </div>
            <p className="stat-card__value">{showtimes}</p>
            <p className="stat-card__description">Tổng số suất chiếu được thiết lập</p>
          </div>
        </Card>

        <Card>
          <div className="stat-card">
            <div className="stat-card__header">
              <span className="stat-card__icon">🎟️</span>
              <span className="stat-card__label">Đơn đặt vé</span>
            </div>
            <p className="stat-card__value">{bookings}</p>
            <p className="stat-card__description">Số đơn đặt vé đã tạo</p>
          </div>
        </Card>

        <Card>
          <div className="stat-card">
            <div className="stat-card__header">
              <span className="stat-card__icon">💡</span>
              <span className="stat-card__label">Khuyến mãi</span>
            </div>
            <p className="stat-card__value">{promotions}</p>
            <p className="stat-card__description">Chương trình khuyến mãi đang hoạt động</p>
          </div>
        </Card>
      </section>

      {/* Main content: 2 cột */}
      <section className="dashboard__main">
        {/* Cột trái: đơn đặt vé gần đây */}
        <div className="dashboard__column">
          <Card
            title="Đơn đặt vé gần đây"
            description="Theo dõi trạng thái thanh toán và xử lý đơn mới nhất."
            actions={
              <a className="link" href="/bookings">
                Xem tất cả
              </a>
            }
          >
            {latestBookingsQuery.isLoading && <LoadingOverlay />}

            {latestBookingsQuery.isError && (
              <ErrorState
                onRetry={() => latestBookingsQuery.refetch()}
                description="Không tải được danh sách đơn đặt vé."
              />
            )}

            {latestBookingsQuery.data && latestBookingsQuery.data.items.length > 0 ? (
              <DataTable
                data={latestBookingsQuery.data.items}
                rowKey={(booking) => booking.id_booking}
                columns={[
                  {
                    key: 'code',
                    title: 'Mã đơn',
                    render: (booking) => booking.booking_code ?? '--',
                  },
                  {
                    key: 'user',
                    title: 'Khách hàng',
                    render: (booking) =>
                      booking.user?.full_name ?? booking.user?.username ?? 'Khách lẻ',
                  },
                  {
                    key: 'amount',
                    title: 'Tổng tiền',
                    render: (booking) => formatCurrency(booking.total_amount),
                  },
                  {
                    key: 'payment-status',
                    title: 'Thanh toán',
                    render: (booking) => (
                      <Badge variant="info">{formatStatus(booking.payment_status)}</Badge>
                    ),
                  },
                  {
                    key: 'booking-status',
                    title: 'Trạng thái',
                    render: (booking) => <StatusDot status={booking.booking_status} />,
                  },
                  {
                    key: 'created',
                    title: 'Ngày đặt',
                    render: (booking) => formatDateTime(booking.booking_date),
                  },
                ]}
              />
            ) : (
              !latestBookingsQuery.isLoading && (
                <EmptyState description="Chưa có đơn đặt vé gần đây." />
              )
            )}
          </Card>
        </div>

        {/* Cột phải: suất chiếu sắp diễn ra */}
        <div className="dashboard__column">
          <Card
            title="Suất chiếu sắp diễn ra"
            description="Kiểm tra nhanh các suất chiếu chuẩn bị bắt đầu."
            actions={
              <a className="link" href="/showtimes">
                Xem tất cả
              </a>
            }
          >
            {upcomingShowtimesQuery.isLoading && <LoadingOverlay />}

            {upcomingShowtimesQuery.isError && (
              <ErrorState
                onRetry={() => upcomingShowtimesQuery.refetch()}
                description="Không tải được suất chiếu."
              />
            )}

            {upcomingShowtimesQuery.data && upcomingShowtimesQuery.data.items.length > 0 ? (
              <DataTable
                data={upcomingShowtimesQuery.data.items}
                rowKey={(showtime) => showtime.id_showtime}
                columns={[
                  {
                    key: 'movie',
                    title: 'Phim',
                    render: (showtime) =>
                      showtime.movie?.title ?? `ID ${showtime.id_movie ?? '-'}`,
                  },
                  {
                    key: 'screen',
                    title: 'Phòng chiếu',
                    render: (showtime) =>
                      showtime.screen?.screen_name ?? `ID ${showtime.id_screen ?? '-'}`,
                  },
                  {
                    key: 'schedule',
                    title: 'Thời gian',
                    render: (showtime) =>
                      `${formatDateTime(showtime.show_date)} · ${formatTime(
                        showtime.start_time,
                      )} - ${formatTime(showtime.end_time)}`,
                  },
                  {
                    key: 'format',
                    title: 'Định dạng',
                    render: (showtime) => showtime.format ?? '--',
                  },
                  {
                    key: 'status',
                    title: 'Trạng thái',
                    render: (showtime) => <StatusDot status={showtime.status} />,
                  },
                ]}
              />
            ) : (
              !upcomingShowtimesQuery.isLoading && (
                <EmptyState description="Chưa có suất chiếu nào." />
              )
            )}
          </Card>
        </div>
      </section>
    </div>
  );
};

export default DashboardPage;

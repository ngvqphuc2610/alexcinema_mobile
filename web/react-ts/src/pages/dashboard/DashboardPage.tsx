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

const DashboardPage = () => {
  const summaryQuery = useQuery({
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
  });

  const latestBookingsQuery = useQuery({
    queryKey: ['dashboard', 'latestBookings'],
    queryFn: () => fetchBookings({ limit: 5 }),
  });

  const upcomingShowtimesQuery = useQuery({
    queryKey: ['dashboard', 'upcomingShowtimes'],
    queryFn: () => fetchShowtimes({ limit: 5 }),
  });

  if (summaryQuery.isLoading) {
    return <LoadingOverlay fullscreen message="Dang tai du lieu tong quan..." />;
  }

  if (summaryQuery.isError) {
    return (
      <ErrorState
        onRetry={() => summaryQuery.refetch()}
        description="Khong tai duoc thong ke. Kiem tra ket noi hoac thu lai sau."
      />
    );
  }

  return (
    <div className="dashboard">
      <div className="dashboard__grid">
        <Card title="Nguoi dung" description="Tong so tai khoan da dang ky">
          <p className="dashboard__stat">{summaryQuery.data?.users ?? 0}</p>
        </Card>
        <Card title="Phim" description="Danh sach phim dang quan ly">
          <p className="dashboard__stat">{summaryQuery.data?.movies ?? 0}</p>
        </Card>
        <Card title="Suat chieu" description="Tong so suat chieu trong he thong">
          <p className="dashboard__stat">{summaryQuery.data?.showtimes ?? 0}</p>
        </Card>
        <Card title="Dat ve" description="So luong don dat ve">
          <p className="dashboard__stat">{summaryQuery.data?.bookings ?? 0}</p>
        </Card>
        <Card title="Khuyen mai" description="Chuong trinh khuyen mai dang hoat dong">
          <p className="dashboard__stat">{summaryQuery.data?.promotions ?? 0}</p>
        </Card>
      </div>

      <div className="dashboard__section">
        <Card
          title="Don dat ve gan day"
          description="Theo doi trang thai thanh toan va xu ly don"
          actions={
            <a className="link" href="/bookings">
              Xem tat ca
            </a>
          }
        >
          {latestBookingsQuery.isLoading && <LoadingOverlay />}
          {latestBookingsQuery.isError && (
            <ErrorState
              onRetry={() => latestBookingsQuery.refetch()}
              description="Khong tai duoc danh sach don dat ve."
            />
          )}
          {latestBookingsQuery.data && latestBookingsQuery.data.items.length > 0 ? (
            <DataTable
              data={latestBookingsQuery.data.items}
              rowKey={(booking) => booking.id_booking}
              columns={[
                {
                  key: 'code',
                  title: 'Ma don',
                  render: (booking) => booking.booking_code ?? '--',
                },
                {
                  key: 'user',
                  title: 'Khach hang',
                  render: (booking) => booking.user?.full_name ?? booking.user?.username ?? 'Khach le',
                },
                {
                  key: 'amount',
                  title: 'Tong tien',
                  render: (booking) => formatCurrency(booking.total_amount),
                },
                {
                  key: 'payment-status',
                  title: 'Thanh toan',
                  render: (booking) => <Badge variant="info">{formatStatus(booking.payment_status)}</Badge>,
                },
                {
                  key: 'booking-status',
                  title: 'Trang thai',
                  render: (booking) => <StatusDot status={booking.booking_status} />,
                },
                {
                  key: 'created',
                  title: 'Ngay dat',
                  render: (booking) => formatDateTime(booking.booking_date),
                },
              ]}
            />
          ) : (
            !latestBookingsQuery.isLoading && <EmptyState description="Chua co don dat ve gan day." />
          )}
        </Card>
      </div>

      <div className="dashboard__section">
        <Card
          title="Suat chieu sap dien ra"
          description="Kiem tra nhanh nhung suat chieu gan nhat"
          actions={
            <a className="link" href="/showtimes">
              Xem tat ca
            </a>
          }
        >
          {upcomingShowtimesQuery.isLoading && <LoadingOverlay />}
          {upcomingShowtimesQuery.isError && (
            <ErrorState
              onRetry={() => upcomingShowtimesQuery.refetch()}
              description="Khong tai duoc suat chieu."
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
                  render: (showtime) => showtime.movie?.title ?? `ID ${showtime.id_movie ?? '-'}`,
                },
                {
                  key: 'screen',
                  title: 'Phong chieu',
                  render: (showtime) => showtime.screen?.screen_name ?? `ID ${showtime.id_screen ?? '-'}`,
                },
                {
                  key: 'schedule',
                  title: 'Thoi gian',
                  render: (showtime) =>
                    `${formatDateTime(showtime.show_date)} - ${formatTime(showtime.start_time)} - ${formatTime(showtime.end_time)}`,
                },
                {
                  key: 'format',
                  title: 'Dinh dang',
                  render: (showtime) => showtime.format ?? '--',
                },
                {
                  key: 'status',
                  title: 'Trang thai',
                  render: (showtime) => <StatusDot status={showtime.status} />,
                },
              ]}
            />
          ) : (
            !upcomingShowtimesQuery.isLoading && <EmptyState description="Chua co suat chieu nao." />
          )}
        </Card>
      </div>
    </div>
  );
};

export default DashboardPage;


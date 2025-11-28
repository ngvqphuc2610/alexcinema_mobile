import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import SearchInput from '../../components/common/SearchInput';
import Pagination from '../../components/common/Pagination';
import EmptyState from '../../components/common/EmptyState';
import ErrorState from '../../components/common/ErrorState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import Modal from '../../components/common/Modal';
import StatusDot from '../../components/common/StatusDot';
import BookingStatusForm from '../../components/forms/BookingStatusForm';
import { fetchBookings, updateBooking, deleteBooking } from '../../api/bookings';
import type { Booking } from '../../types';
import { formatCurrency, formatDateTime, formatStatus } from '../../utils/format';

const mapBookingToFormValues = (booking: Booking) => ({
  paymentStatus: booking.payment_status ?? '',
  bookingStatus: booking.booking_status ?? '',
  bookingCode: booking.booking_code ?? '',
});

const ITEMS_PER_PAGE = 10;

const BookingsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editingBooking, setEditingBooking] = useState<Booking | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['bookings', { page, search }],
    queryFn: () =>
      fetchBookings({
        page,
        limit: ITEMS_PER_PAGE,
        bookingCode: search || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  const updateMutation = useMutation({
    mutationFn: (payload: { id: number; data: { paymentStatus: string; bookingStatus: string; bookingCode?: string } }) =>
      updateBooking(payload.id, {
        paymentStatus: payload.data.paymentStatus,
        bookingStatus: payload.data.bookingStatus,
        bookingCode: payload.data.bookingCode,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['bookings'] });
      setEditingBooking(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteBooking(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['bookings'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (booking: Booking) => {
    if (window.confirm(`Ban chac chan muon xoa don ${booking.booking_code ?? booking.id_booking}?`)) {
      deleteMutation.mutate(booking.id_booking);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'code',
        title: 'Ma don',
        render: (booking: Booking) => booking.booking_code ?? '--',
      },
      {
        key: 'user',
        title: 'Khach hang',
        render: (booking: Booking) => booking.user?.full_name ?? booking.user?.username ?? 'Khach le',
      },
      {
        key: 'showtime',
        title: 'Suat chieu',
        render: (booking: Booking) =>
          booking.showtime
            ? `${booking.showtime.movie?.title ?? `ID ${booking.showtime.id_movie ?? '-'}`} - ${formatDateTime(booking.showtime.show_date)}`
            : '--',
      },
      {
        key: 'total',
        title: 'Tong tien',
        render: (booking: Booking) => formatCurrency(booking.total_amount),
      },
      {
        key: 'payment',
        title: 'Thanh toan',
        render: (booking: Booking) => <StatusDot status={booking.payment_status}>{formatStatus(booking.payment_status)}</StatusDot>,
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (booking: Booking) => <StatusDot status={booking.booking_status}>{formatStatus(booking.booking_status)}</StatusDot>,
      },
      {
        key: 'date',
        title: 'Ngay dat',
        render: (booking: Booking) => formatDateTime(booking.booking_date),
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (booking: Booking) => (
          <div className="table-actions">
            <button type="button" title="Cap nhat trang thai" onClick={() => setEditingBooking(booking)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(booking)}>
              <Trash2 size={16} />
            </button>
          </div>
        ),
      },
    ],
    [],
  );

  return (
    <div className="page">
      <Card
        title="Quan ly don dat ve"
        description="Theo doi trang thai thanh toan va xu ly don."
        actions={
          <SearchInput
            placeholder="Tim theo ma don..."
            onSearch={(value) => {
              setPage(1);
              setSearch(value);
            }}
          />
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach don dat ve." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co don dat ve nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(booking) => booking.id_booking} />
            {meta && (
              <Pagination
                page={page}
                totalPages={meta.totalPages}
                total={meta.total}
                onChange={(nextPage) => setPage(nextPage)}
              />
            )}
          </>
        )}
      </Card>

      <Modal
        open={Boolean(editingBooking)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingBooking(null);
          }
        }}
        title={editingBooking ? `Cap nhat don ${editingBooking.booking_code ?? editingBooking.id_booking}` : ''}
      >
        {editingBooking && (
          <BookingStatusForm
            defaultValues={mapBookingToFormValues(editingBooking)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingBooking(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingBooking.id_booking,
                data: {
                  paymentStatus: values.paymentStatus,
                  bookingStatus: values.bookingStatus,
                  bookingCode: values.bookingCode,
                },
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default BookingsPage;

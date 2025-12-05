import { useMemo, useState, useCallback } from 'react';
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import Button from '../../components/common/Button';
import DataTable from '../../components/common/DataTable';
import EmptyState from '../../components/common/EmptyState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import Pagination from '../../components/common/Pagination';
import Modal from '../../components/common/Modal';
import SearchInput from '../../components/common/SearchInput';
import SeatForm, { type SeatFormValues } from '../../components/forms/SeatForm';
import { fetchSeats, createSeat, updateSeat, deleteSeat } from '../../api/seats';
import { fetchScreens } from '../../api/screens';
import type { Screen, Seat } from '../../types';
import { formatStatus } from '../../utils/format';
import StatusDot from '../../components/common/StatusDot';

const mapSeatToFormValues = (seat: Seat): SeatFormValues => ({
  idScreen: seat.id_screen ?? undefined,
  idSeatType: seat.id_seattype ?? undefined,
  seatRow: seat.seat_row,
  seatNumber: seat.seat_number,
  status: seat.status ?? '',
});

const ITEMS_PER_PAGE = 20;

const SeatsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [filterScreenId, setFilterScreenId] = useState<number | undefined>();
  const [filterSeatTypeId, setFilterSeatTypeId] = useState<number | undefined>();
  const [editingSeat, setEditingSeat] = useState<Seat | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['seats', { page, search, filterScreenId, filterSeatTypeId }],
    queryFn: () =>
      fetchSeats({
        page,
        limit: ITEMS_PER_PAGE,
        seatRow: search || undefined,
        screenId: filterScreenId,
        seatTypeId: filterSeatTypeId,
      }),
    placeholderData: keepPreviousData,
  });

  const screensQuery = useQuery({
    queryKey: ['screens', 'options'],
    queryFn: () => fetchScreens({ limit: 200 }),
  });

  const createMutation = useMutation({
    mutationFn: (values: SeatFormValues) => createSeat(values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['seats'] });
      setCreateModalOpen(false);
      setError(null);
    },
    onError: (err: any) => {
      const message = err?.response?.data?.message || err?.message || 'Loi khi them ghe';
      setError(message);
      console.error('Create seat error:', err);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: SeatFormValues }) => updateSeat(id, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['seats'] });
      setEditingSeat(null);
      setError(null);
    },
    onError: (err: any) => {
      const message = err?.response?.data?.message || err?.message || 'Loi khi cap nhat ghe';
      setError(message);
      console.error('Update seat error:', err);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteSeat(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['seats'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;
  const screenOptions: Screen[] = screensQuery.data?.items ?? [];

  const handleDelete = (seat: Seat) => {
    if (window.confirm(`Xoa ghe ${seat.seat_row}${seat.seat_number}?`)) {
      deleteMutation.mutate(seat.id_seats);
    }
  };

  const handleSearchChange = useCallback((value: string) => {
    setPage(1);
    setSearch(value);
  }, []);

  const columns = useMemo(
    () => [
      {
        key: 'code',
        title: 'Ghe',
        render: (seat: Seat) => `${seat.seat_row}${seat.seat_number}`,
      },
      {
        key: 'screen',
        title: 'Phong chieu',
        render: (seat: Seat) => seat.id_screen ?? '--',
      },
      {
        key: 'seatType',
        title: 'Loai ghe',
        render: (seat: Seat) => seat.id_seattype ?? '--',
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (seat: Seat) => <StatusDot status={seat.status}>{formatStatus(seat.status)}</StatusDot>,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (seat: Seat) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingSeat(seat)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(seat)}>
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
        title="So do ghe"
        description="Quan ly ghe cho tung phong."
        actions={
          <div className="card__actions-group">
            <select
              value={filterScreenId ?? ''}
              onChange={(e) => {
                setPage(1);
                setFilterScreenId(e.target.value ? Number(e.target.value) : undefined);
              }}
              className="filter-select"
              title="Loc theo phong chieu"
            >
              <option value="">-- Tat ca phong --</option>
              {screenOptions.map((screen) => (
                <option key={screen.id_screen} value={screen.id_screen}>
                  {screen.screen_name}
                </option>
              ))}
            </select>
            <select
              value={filterSeatTypeId ?? ''}
              onChange={(e) => {
                setPage(1);
                setFilterSeatTypeId(e.target.value ? Number(e.target.value) : undefined);
              }}
              className="filter-select"
              title="Loc theo loai ghe"
            >
              <option value="">-- Tat ca loai ghe --</option>
              <option value="1">VIP</option>
              <option value="2">Standard</option>
              <option value="3">Economy</option>
            </select>
            <SearchInput
              placeholder="Tim theo hang ghe..."
              onSearch={handleSearchChange}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)} disabled={screensQuery.isLoading}>
              Them ghe
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach ghe." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co ghe nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(seat) => seat.id_seats} />
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

      <Modal open={isCreateModalOpen} onClose={() => {
        setCreateModalOpen(false);
        setError(null);
      }} title="Them ghe">
        {error && <div style={{ color: '#ef4444', marginBottom: '12px', padding: '8px', backgroundColor: '#fee2e2', borderRadius: '6px', fontSize: '14px' }}>{error}</div>}
        <SeatForm
          screens={screenOptions}
          isSubmitting={createMutation.isPending}
          onCancel={() => {
            setCreateModalOpen(false);
            setError(null);
          }}
          onSubmit={(values) => createMutation.mutate(values)}
        />
      </Modal>

      <Modal
        open={Boolean(editingSeat)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingSeat(null);
            setError(null);
          }
        }}
        title={editingSeat ? `Chinh sua ghe ${editingSeat.seat_row}${editingSeat.seat_number}` : ''}
      >
        {error && <div style={{ color: '#ef4444', marginBottom: '12px', padding: '8px', backgroundColor: '#fee2e2', borderRadius: '6px', fontSize: '14px' }}>{error}</div>}
        {editingSeat && (
          <SeatForm
            screens={screenOptions}
            defaultValues={mapSeatToFormValues(editingSeat)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => {
              setEditingSeat(null);
              setError(null);
            }}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingSeat.id_seats,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default SeatsPage;


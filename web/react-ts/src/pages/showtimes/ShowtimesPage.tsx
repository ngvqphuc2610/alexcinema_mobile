import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import Pagination from '../../components/common/Pagination';
import Button from '../../components/common/Button';
import EmptyState from '../../components/common/EmptyState';
import ErrorState from '../../components/common/ErrorState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import Modal from '../../components/common/Modal';
import StatusDot from '../../components/common/StatusDot';
import ShowtimeForm from '../../components/forms/ShowtimeForm';
import { fetchShowtimes, createShowtime, updateShowtime, deleteShowtime } from '../../api/showtimes';
import { fetchMovies } from '../../api/movies';
import { fetchScreens } from '../../api/screens';
import type { Showtime } from '../../types';
import { formatCurrency, formatDateTime, formatStatus, formatTime } from '../../utils/format';

const ShowtimesPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [editingShowtime, setEditingShowtime] = useState<Showtime | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const showtimesQuery = useQuery({
    queryKey: ['showtimes', { page }],
    queryFn: () =>
      fetchShowtimes({
        page,
      }),
    placeholderData: keepPreviousData,
  });

  const moviesQuery = useQuery({
    queryKey: ['showtimes', 'movies'],
    queryFn: () => fetchMovies({ limit: 100 }),
  });

  const screensQuery = useQuery({
    queryKey: ['showtimes', 'screens'],
    queryFn: () => fetchScreens({ limit: 100 }),
  });

  const createMutation = useMutation({
    mutationFn: createShowtime,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['showtimes'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: (payload: { id: number; data: Parameters<typeof createShowtime>[0] }) =>
      updateShowtime(payload.id, payload.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['showtimes'] });
      setEditingShowtime(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteShowtime(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['showtimes'] }),
  });

  const showtimes = showtimesQuery.data?.items ?? [];
  const meta = showtimesQuery.data?.meta;
  const movies = moviesQuery.data?.items ?? [];
  const screens = screensQuery.data?.items ?? [];

  const handleDelete = (showtime: Showtime) => {
    if (window.confirm('Ban chac chan muon xoa suat chieu nay?')) {
      deleteMutation.mutate(showtime.id_showtime);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'movie',
        title: 'Phim',
        render: (showtime: Showtime) => showtime.movie?.title ?? `ID ${showtime.id_movie ?? '-'}`,
      },
      {
        key: 'screen',
        title: 'Phong chieu',
        render: (showtime: Showtime) => showtime.screen?.screen_name ?? `ID ${showtime.id_screen ?? '-'}`,
      },
      {
        key: 'date',
        title: 'Ngay',
        render: (showtime: Showtime) => formatDateTime(showtime.show_date),
      },
      {
        key: 'time',
        title: 'Gio',
        render: (showtime: Showtime) => `${formatTime(showtime.start_time)} - ${formatTime(showtime.end_time)}`,
      },
      {
        key: 'price',
        title: 'Gia ve',
        render: (showtime: Showtime) => formatCurrency(showtime.price),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (showtime: Showtime) => <StatusDot status={showtime.status}>{formatStatus(showtime.status)}</StatusDot>,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (showtime: Showtime) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingShowtime(showtime)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(showtime)}>
              <Trash2 size={16} />
            </button>
          </div>
        ),
      },
    ],
    [],
  );

  const movieOptions = moviesQuery.isSuccess ? movies : [];
  const screenOptions = screensQuery.isSuccess ? screens : [];

  return (
    <div className="page">
      <Card
        title="Quan ly suat chieu"
        description="Tao moi, chinh sua va theo doi lich chieu."
        actions={
          <div className="card__actions-group">
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)}>
              Them suat chieu
            </Button>
          </div>
        }
      >
        {showtimesQuery.isLoading && <LoadingOverlay />}
        {showtimesQuery.isError && (
          <ErrorState description="Khong tai duoc danh sach suat chieu." onRetry={() => showtimesQuery.refetch()} />
        )}
        {!showtimesQuery.isLoading && showtimes.length === 0 && (
          <EmptyState description="Chua co suat chieu nao trong he thong." />
        )}
        {!showtimesQuery.isLoading && showtimes.length > 0 && (
          <>
            <DataTable data={showtimes} columns={columns} rowKey={(showtime) => showtime.id_showtime} />
            {meta && (
              <Pagination
                page={meta.page}
                totalPages={meta.totalPages}
                total={meta.total}
                onChange={(nextPage) => setPage(nextPage)}
              />
            )}
          </>
        )}
      </Card>

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them suat chieu moi">
        <ShowtimeForm
          movies={movieOptions}
          screens={screenOptions}
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) =>
            createMutation.mutate({
              idMovie: values.idMovie,
              idScreen: values.idScreen,
              showDate: values.showDate,
              startTime: values.startTime,
              endTime: values.endTime,
              format: values.format,
              language: values.language,
              subtitle: values.subtitle,
              status: values.status,
              price: values.price,
            })
          }
        />
      </Modal>

      <Modal
        open={Boolean(editingShowtime)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingShowtime(null);
          }
        }}
        title={editingShowtime ? 'Chinh sua suat chieu' : ''}
      >
        {editingShowtime && (
          <ShowtimeForm
            movies={movieOptions}
            screens={screenOptions}
            defaultValues={{
              idMovie: editingShowtime.id_movie ?? undefined,
              idScreen: editingShowtime.id_screen ?? undefined,
              showDate: editingShowtime.show_date.substring(0, 10),
              startTime: formatTime(editingShowtime.start_time),
              endTime: formatTime(editingShowtime.end_time),
              format: editingShowtime.format ?? '',
              language: editingShowtime.language ?? '',
              subtitle: editingShowtime.subtitle ?? '',
              status: editingShowtime.status ?? '',
              price: Number(editingShowtime.price),
            }}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingShowtime(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingShowtime.id_showtime,
                data: {
                  idMovie: values.idMovie,
                  idScreen: values.idScreen,
                  showDate: values.showDate,
                  startTime: values.startTime,
                  endTime: values.endTime,
                  format: values.format,
                  language: values.language,
                  subtitle: values.subtitle,
                  status: values.status,
                  price: values.price,
                },
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default ShowtimesPage;

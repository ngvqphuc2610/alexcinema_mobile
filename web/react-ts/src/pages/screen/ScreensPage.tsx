import { useMemo, useState } from 'react';
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
import StatusDot from '../../components/common/StatusDot';
import ScreenForm, { type ScreenFormValues } from '../../components/forms/ScreenForm';
import SearchInput from '../../components/common/SearchInput';
import { fetchScreens, createScreen, updateScreen, deleteScreen } from '../../api/screens';
import { fetchCinemas } from '../../api/cinemas';
import type { Cinema, Screen } from '../../types';
import { formatStatus } from '../../utils/format';

const mapToFormValues = (screen: Screen): ScreenFormValues => ({
  idCinema: screen.id_cinema ?? undefined,
  screenName: screen.screen_name,
  capacity: screen.capacity,
  status: screen.status ?? '',
  idScreenType: screen.id_screentype ?? undefined,
});

const toPayload = (values: ScreenFormValues) => ({
  idCinema: values.idCinema,
  idScreenType: values.idScreenType,
  screenName: values.screenName,
  capacity: values.capacity,
  status: values.status,
});

const ScreensPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editing, setEditing] = useState<Screen | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['screens', { page, search }],
    queryFn: () => fetchScreens({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const cinemasQuery = useQuery({
    queryKey: ['cinemas', 'options'],
    queryFn: () => fetchCinemas({ limit: 100 }),
  });

  const createMutation = useMutation({
    mutationFn: (values: ScreenFormValues) => createScreen(toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['screens'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: ScreenFormValues }) => updateScreen(id, toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['screens'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteScreen(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['screens'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;
  const cinemaOptions: Cinema[] = cinemasQuery.data?.items ?? [];

  const handleDelete = (screen: Screen) => {
    if (window.confirm(`Ban chac chan muon xoa phong ${screen.screen_name}?`)) {
      deleteMutation.mutate(screen.id_screen);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'name',
        title: 'Ten phong',
        render: (screen: Screen) => screen.screen_name,
      },
      {
        key: 'cinema',
        title: 'Rap',
        render: (screen: Screen) => screen.cinema?.cinema_name ?? `ID ${screen.id_cinema ?? '--'}`,
      },
      {
        key: 'capacity',
        title: 'Suc chua',
        render: (screen: Screen) => `${screen.capacity} ghe`,
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (screen: Screen) => <StatusDot status={screen.status}>{formatStatus(screen.status)}</StatusDot>,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (screen: Screen) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditing(screen)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(screen)}>
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
        title="Phong chieu"
        description="Quan ly phong chieu va suc chua."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim phong..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)} disabled={cinemasQuery.isLoading}>
              Them phong
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach phong." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co phong nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(screen) => screen.id_screen} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them phong chieu">
        <ScreenForm
          cinemas={cinemaOptions}
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) => createMutation.mutate(values)}
        />
      </Modal>

      <Modal
        open={Boolean(editing)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditing(null);
          }
        }}
        title={editing ? `Chinh sua: ${editing.screen_name}` : ''}
      >
        {editing && (
          <ScreenForm
            cinemas={cinemaOptions}
            defaultValues={mapToFormValues(editing)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditing(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editing.id_screen,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default ScreensPage;


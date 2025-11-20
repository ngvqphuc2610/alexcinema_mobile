import { useMemo, useState } from 'react';
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import SearchInput from '../../components/common/SearchInput';
import Button from '../../components/common/Button';
import DataTable from '../../components/common/DataTable';
import EmptyState from '../../components/common/EmptyState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import Pagination from '../../components/common/Pagination';
import Modal from '../../components/common/Modal';
import StatusDot from '../../components/common/StatusDot';
import CinemaForm, { type CinemaFormValues } from '../../components/forms/CinemaForm';
import { deleteCinema, fetchCinemas, createCinema, updateCinema } from '../../api/cinemas';
import type { Cinema } from '../../types';
import { formatStatus } from '../../utils/format';

const toFormValues = (cinema: Cinema): CinemaFormValues => ({
  cinemaName: cinema.cinema_name,
  address: cinema.address,
  city: cinema.city,
  description: cinema.description ?? '',
  image: cinema.image ?? '',
  contactNumber: cinema.contact_number ?? '',
  email: cinema.email ?? '',
  status: cinema.status ?? '',
});

const toPayload = (values: CinemaFormValues) => ({
  cinemaName: values.cinemaName,
  address: values.address,
  city: values.city,
  description: values.description || undefined,
  image: values.image || undefined,
  contactNumber: values.contactNumber || undefined,
  email: values.email || undefined,
  status: values.status || undefined,
});

const CinemasPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);
  const [editingCinema, setEditingCinema] = useState<Cinema | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['cinemas', { page, search }],
    queryFn: () => fetchCinemas({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const createMutation = useMutation({
    mutationFn: (values: CinemaFormValues) => createCinema(toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cinemas'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: CinemaFormValues }) => updateCinema(id, toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cinemas'] });
      setEditingCinema(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteCinema(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['cinemas'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (cinema: Cinema) => {
    if (window.confirm(`Ban chac chan muon xoa rap ${cinema.cinema_name}?`)) {
      deleteMutation.mutate(cinema.id_cinema);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'name',
        title: 'Ten rap',
        render: (cinema: Cinema) => cinema.cinema_name,
      },
      {
        key: 'city',
        title: 'Thanh pho',
        render: (cinema: Cinema) => cinema.city,
      },
      {
        key: 'contact',
        title: 'Lien he',
        render: (cinema: Cinema) => (
          <div className="table__stack">
            <span>{cinema.contact_number ?? '--'}</span>
            <span className="text-muted">{cinema.email ?? '--'}</span>
          </div>
        ),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (cinema: Cinema) => <StatusDot status={cinema.status}>{formatStatus(cinema.status)}</StatusDot>,
      },
      {
        key: 'stats',
        title: 'Phong / Gio hoat dong',
        render: (cinema: Cinema) => `${cinema._count?.screens ?? 0} / ${cinema._count?.operation_hours ?? 0}`,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (cinema: Cinema) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingCinema(cinema)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(cinema)}>
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
        title="Quan ly rap chieu"
        description="Them moi, cap nhat dia diem va thong tin rap."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim theo ten hoac dia chi..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)}>
              Them rap
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach rap." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co rap nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(cinema) => cinema.id_cinema} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them rap moi">
        <CinemaForm
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) => createMutation.mutate(values)}
        />
      </Modal>

      <Modal
        open={Boolean(editingCinema)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingCinema(null);
          }
        }}
        title={editingCinema ? `Chinh sua: ${editingCinema.cinema_name}` : ''}
      >
        {editingCinema && (
          <CinemaForm
            defaultValues={toFormValues(editingCinema)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingCinema(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingCinema.id_cinema,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default CinemasPage;

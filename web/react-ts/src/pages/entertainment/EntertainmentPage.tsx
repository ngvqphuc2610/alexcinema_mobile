import { useMemo, useState } from 'react';
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import Button from '../../components/common/Button';
import SearchInput from '../../components/common/SearchInput';
import DataTable from '../../components/common/DataTable';
import EmptyState from '../../components/common/EmptyState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import Pagination from '../../components/common/Pagination';
import Modal from '../../components/common/Modal';
import StatusDot from '../../components/common/StatusDot';
import EntertainmentForm, { type EntertainmentFormValues } from '../../components/forms/EntertainmentForm';
import { fetchEntertainment, createEntertainment, updateEntertainment, deleteEntertainment } from '../../api/entertainment';
import { fetchCinemas } from '../../api/cinemas';
import { fetchStaff } from '../../api/staff';
import type { Cinema, Entertainment, Staff } from '../../types';
import { formatDate, formatStatus } from '../../utils/format';

const mapToFormValues = (item: Entertainment): EntertainmentFormValues => ({
  idCinema: item.id_cinema ?? undefined,
  title: item.title,
  description: item.description ?? '',
  imageUrl: item.image_url ?? '',
  startDate: item.start_date.substring(0, 10),
  endDate: item.end_date ? item.end_date.substring(0, 10) : '',
  status: item.status ?? '',
  viewsCount: item.views_count ?? undefined,
  featured: item.featured ?? undefined,
  idStaff: item.id_staff ?? undefined,
});

const EntertainmentPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editingItem, setEditingItem] = useState<Entertainment | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['entertainment', { page, search }],
    queryFn: () =>
      fetchEntertainment({
        page,
        search: search || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  const cinemasQuery = useQuery({
    queryKey: ['cinemas', 'options'],
    queryFn: () => fetchCinemas({ limit: 100 }),
  });

  const staffQuery = useQuery({
    queryKey: ['staff', 'options'],
    queryFn: () => fetchStaff({ limit: 100 }),
  });

  const createMutation = useMutation({
    mutationFn: (values: EntertainmentFormValues) =>
      createEntertainment({
        ...values,
        endDate: values.endDate || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['entertainment'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: EntertainmentFormValues }) =>
      updateEntertainment(id, {
        ...values,
        endDate: values.endDate || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['entertainment'] });
      setEditingItem(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteEntertainment(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['entertainment'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;
  const cinemaOptions: Cinema[] = cinemasQuery.data?.items ?? [];
  const staffOptions: Staff[] = staffQuery.data?.items ?? [];

  const handleDelete = (item: Entertainment) => {
    if (window.confirm(`Xoa su kien "${item.title}"?`)) {
      deleteMutation.mutate(item.id_entertainment);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'title',
        title: 'Tieu de',
        render: (item: Entertainment) => item.title,
      },
      {
        key: 'image',
        title: 'Anh',
        render: (item: Entertainment) =>
          item.image_url ? (
            <img
              src={item.image_url}
              alt={item.title}
              className="table-image table-image--landscape"
            />
          ) : (
            '--'
          ),
      },
      {
        key: 'cinema',
        title: 'Rap',
        render: (item: Entertainment) => item.id_cinema ?? '--',
      },
      {
        key: 'date',
        title: 'Thoi gian',
        render: (item: Entertainment) => `${formatDate(item.start_date)} - ${formatDate(item.end_date)}`,
      },
      {
        key: 'featured',
        title: 'Noi bat',
        render: (item: Entertainment) => (item.featured ? 'Co' : 'Khong'),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (item: Entertainment) => <StatusDot status={item.status}>{formatStatus(item.status)}</StatusDot>,
      },
      {
        key: 'views',
        title: 'Luot xem',
        render: (item: Entertainment) => item.views_count ?? 0,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (item: Entertainment) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingItem(item)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(item)}>
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
        title="Su kien / Giai tri"
        description="Quan ly cac chuong trinh giai tri tai rap."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim kiem su kien..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button
              leftIcon={<Plus size={16} />}
              onClick={() => setCreateModalOpen(true)}
              disabled={cinemasQuery.isLoading || staffQuery.isLoading}
            >
              Them su kien
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach su kien." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co su kien nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(item) => item.id_entertainment} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them su kien">
        <EntertainmentForm
          cinemas={cinemaOptions}
          staff={staffOptions}
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) => createMutation.mutate(values)}
        />
      </Modal>

      <Modal
        open={Boolean(editingItem)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingItem(null);
          }
        }}
        title={editingItem ? `Chinh sua: ${editingItem.title}` : ''}
      >
        {editingItem && (
          <EntertainmentForm
            cinemas={cinemaOptions}
            staff={staffOptions}
            defaultValues={mapToFormValues(editingItem)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingItem(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingItem.id_entertainment,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default EntertainmentPage;

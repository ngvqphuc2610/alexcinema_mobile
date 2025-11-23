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
import MembershipForm, { type MembershipFormValues } from '../../components/forms/MembershipForm';
import { fetchMemberships, createMembership, updateMembership, deleteMembership } from '../../api/memberships';
import type { Membership } from '../../types';
import { formatStatus } from '../../utils/format';

const toFormValues = (membership: Membership): MembershipFormValues => ({
  code: membership.code,
  title: membership.title,
  image: membership.image ?? '',
  link: membership.link ?? '',
  description: membership.description ?? '',
  benefits: membership.benefits ?? '',
  criteria: membership.criteria ?? '',
  status: membership.status ?? '',
});

const MembershipsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editing, setEditing] = useState<Membership | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['memberships', { page, search }],
    queryFn: () => fetchMemberships({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const createMutation = useMutation({
    mutationFn: (values: MembershipFormValues) => createMembership(values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['memberships'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: MembershipFormValues }) => updateMembership(id, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['memberships'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteMembership(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['memberships'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (membership: Membership) => {
    if (window.confirm(`Ban chac chan muon xoa hang ${membership.title}?`)) {
      deleteMutation.mutate(membership.id_membership);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'image',
        title: 'Anh',
        render: (membership: Membership) =>
          membership.image ? (
            <img src={membership.image} alt={membership.title} className="table-image table-image--square" />
          ) : (
            '--'
          ),
      },
      {
        key: 'code',
        title: 'Ma',
        render: (membership: Membership) => membership.code,
      },
      {
        key: 'title',
        title: 'Ten hang',
        render: (membership: Membership) => membership.title,
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (membership: Membership) => (
          <StatusDot status={membership.status}>{formatStatus(membership.status)}</StatusDot>
        ),
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (membership: Membership) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditing(membership)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(membership)}>
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
        title="Hang thanh vien"
        description="Quan ly cac chuong trinh membership."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim theo ma hoac ten..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)}>
              Them hang
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach membership." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co hang thanh vien nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(item) => item.id_membership} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them hang thanh vien">
        <MembershipForm
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
        title={editing ? `Chinh sua: ${editing.title}` : ''}
      >
        {editing && (
          <MembershipForm
            defaultValues={toFormValues(editing)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditing(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editing.id_membership,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default MembershipsPage;

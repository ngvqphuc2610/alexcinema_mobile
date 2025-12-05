import { useMemo, useState, useCallback, useEffect } from 'react';
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
import MemberForm, { type MemberFormValues } from '../../components/forms/MemberForm';
import { fetchMembers, createMember, updateMember, deleteMember } from '../../api/members';
import type { Member } from '../../types';
import { formatDate, formatStatus } from '../../utils/format';

const mapToFormValues = (member: Member): MemberFormValues => ({
  idUser: member.id_user ?? undefined,
  idTypeMember: member.id_typemember ?? undefined,
  idMembership: member.id_membership ?? undefined,
  points: member.points ?? undefined,
  joinDate: member.join_date ? member.join_date.substring(0, 10) : '',
  status: member.status ?? '',
});

const toPayload = (values: MemberFormValues) => ({
  idUser: values.idUser!,
  idTypeMember: values.idTypeMember!,
  idMembership: values.idMembership,
  points: values.points,
  joinDate: values.joinDate,
  status: values.status,
});

const MembersPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [userFilter, setUserFilter] = useState<number | undefined>(undefined);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);
  const [editingMember, setEditingMember] = useState<Member | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['members', { page, userFilter }],
    queryFn: () =>
      fetchMembers({
        page,
        userId: userFilter,
      }),
    placeholderData: keepPreviousData,
  });

  // Debug logs
  useEffect(() => {
    console.log('[MembersPage] page state changed to:', page);
  }, [page]);

  useEffect(() => {
    console.log('[MembersPage] userFilter changed to:', userFilter);
  }, [userFilter]);

  useEffect(() => {
    console.log('[MembersPage] Query will fetch with:', { page, userFilter });
  }, [page, userFilter]);

  useEffect(() => {
    console.log('[MembersPage] Data received:', {
      items: data?.items?.length ?? 0,
      meta: data?.meta,
      isLoading,
    });
  }, [data, isLoading]);

  const createMutation = useMutation({
    mutationFn: (values: MemberFormValues) => createMember(toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['members'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: MemberFormValues }) =>
      updateMember(id, {
        ...values,
        idUser: values.idUser,
        idTypeMember: values.idTypeMember,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['members'] });
      setEditingMember(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteMember(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['members'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (member: Member) => {
    if (window.confirm(`Xoa thanh vien cua ${member.user?.full_name ?? member.id_member}?`)) {
      deleteMutation.mutate(member.id_member);
    }
  };

  const handleSearchChange = useCallback((value: string) => {
    console.log('[MembersPage] handleSearchChange called with:', value);
    const trimmed = value.trim();
    const parsed = trimmed ? Number(trimmed) : NaN;
    setPage(1);
    setUserFilter(Number.isNaN(parsed) ? undefined : parsed);
  }, []);

  const columns = useMemo(
    () => [
      {
        key: 'user',
        title: 'Nguoi dung',
        render: (member: Member) => member.user?.full_name ?? member.user?.username ?? `ID ${member.id_user ?? '-'}`,
      },
      {
        key: 'type',
        title: 'Hang',
        render: (member: Member) => member.type_member?.type_name ?? member.id_typemember ?? '--',
      },
      {
        key: 'membership',
        title: 'Program',
        render: (member: Member) => member.membership?.title ?? '--',
      },
      {
        key: 'points',
        title: 'Diem',
        render: (member: Member) => member.points ?? 0,
      },
      {
        key: 'joinDate',
        title: 'Ngay tham gia',
        render: (member: Member) => formatDate(member.join_date),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (member: Member) => <StatusDot status={member.status}>{formatStatus(member.status)}</StatusDot>,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (member: Member) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingMember(member)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(member)}>
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
        title="Thanh vien"
        description="Quan ly hang thanh vien va diem tich luy."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Nhap ID user de loc..."
              onSearch={handleSearchChange}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)}>
              Them thanh vien
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach thanh vien." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co thanh vien nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(member) => member.id_member} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them thanh vien">
        <MemberForm
          mode="create"
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) => createMutation.mutate(values)}
        />
      </Modal>

      <Modal
        open={Boolean(editingMember)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingMember(null);
          }
        }}
        title={editingMember ? `Chinh sua thanh vien ${editingMember.user?.full_name ?? editingMember.id_member}` : ''}
      >
        {editingMember && (
          <MemberForm
            mode="edit"
            defaultValues={mapToFormValues(editingMember)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingMember(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingMember.id_member,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default MembersPage;

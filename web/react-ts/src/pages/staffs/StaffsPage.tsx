import { useMemo, useState } from 'react';
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2, KeyRound } from 'lucide-react';
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
import StaffForm, { type StaffFormValues } from '../../components/forms/StaffForm';
import StaffPasswordForm from '../../components/forms/StaffPasswordForm';
import { fetchStaff, createStaff, updateStaff, deleteStaff, updateStaffPassword } from '../../api/staff';
import { fetchTypeStaff } from '../../api/typeStaff';
import type { Staff, TypeStaff } from '../../types';
import { formatDate, formatStatus } from '../../utils/format';

const mapToFormValues = (staff: Staff): StaffFormValues => ({
  idTypeStaff: staff.id_typestaff ?? undefined,
  staffName: staff.staff_name,
  email: staff.email,
  phoneNumber: staff.phone_number ?? '',
  address: staff.address ?? '',
  dateOfBirth: staff.date_of_birth ? staff.date_of_birth.substring(0, 10) : '',
  hireDate: staff.hire_date ? staff.hire_date.substring(0, 10) : '',
  status: staff.status ?? '',
  profileImage: staff.profile_image ?? '',
});

const StaffsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editing, setEditing] = useState<Staff | null>(null);
  const [passwordTarget, setPasswordTarget] = useState<Staff | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['staff', { page, search }],
    queryFn: () => fetchStaff({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const staffTypesQuery = useQuery({
    queryKey: ['type-staff', 'options'],
    queryFn: () => fetchTypeStaff({ limit: 100 }),
  });

  const createMutation = useMutation({
    mutationFn: (values: StaffFormValues) =>
      createStaff({
        idTypeStaff: values.idTypeStaff,
        staffName: values.staffName,
        email: values.email,
        password: values.password ?? '',
        phoneNumber: values.phoneNumber,
        address: values.address,
        dateOfBirth: values.dateOfBirth,
        hireDate: values.hireDate,
        status: values.status,
        profileImage: values.profileImage,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['staff'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: StaffFormValues }) =>
      updateStaff(id, {
        idTypeStaff: values.idTypeStaff,
        staffName: values.staffName,
        email: values.email,
        phoneNumber: values.phoneNumber,
        address: values.address,
        dateOfBirth: values.dateOfBirth,
        hireDate: values.hireDate,
        status: values.status,
        profileImage: values.profileImage,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['staff'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteStaff(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['staff'] }),
  });

  const passwordMutation = useMutation({
    mutationFn: ({ id, password }: { id: number; password: string }) => updateStaffPassword(id, password),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['staff'] });
      setPasswordTarget(null);
    },
  });

  const items = data?.items ?? [];
  const meta = data?.meta;
  const staffTypes: TypeStaff[] = staffTypesQuery.data?.items ?? [];

  const handleDelete = (staff: Staff) => {
    if (window.confirm(`Xoa nhan vien ${staff.staff_name}?`)) {
      deleteMutation.mutate(staff.id_staff);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'name',
        title: 'Ho ten',
        render: (staff: Staff) => (
          <div className="table__stack">
            <span>{staff.staff_name}</span>
            <span className="text-muted">{staff.email}</span>
          </div>
        ),
      },
      {
        key: 'type',
        title: 'Loai',
        render: (staff: Staff) => staff.type_staff?.type_name ?? '--',
      },
      {
        key: 'phone',
        title: 'Lien he',
        render: (staff: Staff) => staff.phone_number ?? '--',
      },
      {
        key: 'hireDate',
        title: 'Ngay vao lam',
        render: (staff: Staff) => formatDate(staff.hire_date),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (staff: Staff) => <StatusDot status={staff.status}>{formatStatus(staff.status)}</StatusDot>,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (staff: Staff) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditing(staff)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Doi mat khau" onClick={() => setPasswordTarget(staff)}>
              <KeyRound size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(staff)}>
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
        title="Nhan vien"
        description="Quan ly thong tin nhan vien va quyen han."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim theo ten hoac email..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button
              leftIcon={<Plus size={16} />}
              onClick={() => setCreateModalOpen(true)}
              disabled={staffTypesQuery.isLoading}
            >
              Them nhan vien
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach nhan vien." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co nhan vien nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(staff) => staff.id_staff} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them nhan vien">
        <StaffForm
          mode="create"
          staffTypes={staffTypes}
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
        title={editing ? `Chinh sua: ${editing.staff_name}` : ''}
      >
        {editing && (
          <StaffForm
            mode="edit"
            staffTypes={staffTypes}
            defaultValues={mapToFormValues(editing)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditing(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editing.id_staff,
                values,
              })
            }
          />
        )}
      </Modal>

      <Modal
        open={Boolean(passwordTarget)}
        onClose={() => {
          if (!passwordMutation.isPending) {
            setPasswordTarget(null);
          }
        }}
        title={passwordTarget ? `Doi mat khau: ${passwordTarget.staff_name}` : ''}
      >
        {passwordTarget && (
          <StaffPasswordForm
            isSubmitting={passwordMutation.isPending}
            onCancel={() => setPasswordTarget(null)}
            onSubmit={(password) =>
              passwordMutation.mutate({
                id: passwordTarget.id_staff,
                password,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default StaffsPage;

import { useMemo, useState, useCallback } from 'react';
import { useMutation, useQuery, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { Pencil, KeyRound, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import SearchInput from '../../components/common/SearchInput';
import Pagination from '../../components/common/Pagination';
import Button from '../../components/common/Button';
import StatusDot from '../../components/common/StatusDot';
import EmptyState from '../../components/common/EmptyState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import Modal from '../../components/common/Modal';
import UserForm from '../../components/forms/UserForm';
import type { UserFormValues } from '../../components/forms/UserForm';
import FormField from '../../components/forms/FormField';
import { fetchUsers, updateUser, deleteUser, updateUserPassword } from '../../api/users';
import type { User } from '../../types';
import { formatDate } from '../../utils/format';

interface PasswordFormState {
  id: number;
  fullName: string;
}

const mapUserToFormValues = (user: User): UserFormValues => ({
  username: user.username,
  email: user.email,
  fullName: user.full_name,
  phoneNumber: user.phone_number ?? '',
  dateOfBirth: user.date_of_birth ? user.date_of_birth.substring(0, 10) : '',
  gender: user.gender ?? '',
  address: user.address ?? '',
  profileImage: user.profile_image ?? '',
  role: (user.role === 'admin' ? 'admin' : 'user'),
  status: (user.status === 'inactive' ? 'inactive' : 'active'),
});

const toUserUpdatePayload = (values: UserFormValues) => ({
  username: values.username,
  email: values.email,
  fullName: values.fullName,
  phoneNumber: values.phoneNumber || undefined,
  dateOfBirth: values.dateOfBirth || undefined,
  gender: values.gender || undefined,
  address: values.address || undefined,
  profileImage: values.profileImage || undefined,
  role: values.role,
  status: values.status,
});

const UsersPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [passwordModal, setPasswordModal] = useState<PasswordFormState | null>(null);
  const [newPassword, setNewPassword] = useState('');

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['users', { page, search }],
    queryFn: () => fetchUsers({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const updateMutation = useMutation({
    mutationFn: (payload: { id: number; values: UserFormValues }) => updateUser(payload.id, toUserUpdatePayload(payload.values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      setEditingUser(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteUser(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  });

  const changePasswordMutation = useMutation({
    mutationFn: ({ id, password }: { id: number; password: string }) => updateUserPassword(id, password),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      setPasswordModal(null);
      setNewPassword('');
    },
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (user: User) => {
    if (window.confirm(`Ban chac chan muon xoa nguoi dung "${user.full_name}"?`)) {
      deleteMutation.mutate(user.id_users);
    }
  };

  const handleSearchChange = useCallback((value: string) => {
    setPage(1);
    setSearch(value);
  }, []);

  const tableColumns = useMemo(
    () => [
      {
        key: 'avatar',
        title: 'Anh',
        render: (user: User) =>
          user.profile_image ? (
            <img src={user.profile_image} alt={user.full_name} className="table-image table-image--square" />
          ) : (
            '--'
          ),
      },
      {
        key: 'username',
        title: 'Ten dang nhap',
        render: (user: User) => user.username,
      },
      {
        key: 'fullName',
        title: 'Ho va ten',
        render: (user: User) => user.full_name,
      },
      {
        key: 'email',
        title: 'Email',
        render: (user: User) => user.email,
      },
      {
        key: 'phone',
        title: 'So dien thoai',
        render: (user: User) => user.phone_number ?? '--',
      },
      {
        key: 'role',
        title: 'Vai tro',
        render: (user: User) => user.role,
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (user: User) => <StatusDot status={user.status} />,
      },
      {
        key: 'created',
        title: 'Ngay tao',
        render: (user: User) => formatDate(user.created_at),
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (user: User) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingUser(user)}>
              <Pencil size={16} />
            </button>
            <button
              type="button"
              title="Doi mat khau"
              onClick={() => setPasswordModal({ id: user.id_users, fullName: user.full_name })}
            >
              <KeyRound size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(user)}>
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
        title="Quan ly nguoi dung"
        description="Theo doi, cap nhat thong tin va trang thai nguoi dung."
        actions={
          <SearchInput
            placeholder="Tim kiem theo ten, email..."
            onSearch={handleSearchChange}
          />
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && (
          <ErrorState description="Khong tai duoc du lieu nguoi dung." onRetry={() => refetch()} />
        )}
        {!isLoading && items.length === 0 && <EmptyState description="Khong co nguoi dung nao phu hop." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={tableColumns} rowKey={(user) => user.id_users} />
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

      <Modal
        open={Boolean(editingUser)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingUser(null);
          }
        }}
        title={editingUser ? `Cap nhat: ${editingUser.full_name}` : ''}
      >
        {editingUser && (
          <UserForm
            mode="edit"
            defaultValues={mapUserToFormValues(editingUser)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingUser(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingUser.id_users,
                values,
              })
            }
          />
        )}
      </Modal>

      <Modal
        open={Boolean(passwordModal)}
        onClose={() => {
          if (!changePasswordMutation.isPending) {
            setPasswordModal(null);
            setNewPassword('');
          }
        }}
        title={passwordModal ? `Doi mat khau: ${passwordModal.fullName}` : ''}
      >
        {passwordModal && (
          <form
            className="form"
            onSubmit={(event) => {
              event.preventDefault();
              changePasswordMutation.mutate({
                id: passwordModal.id,
                password: newPassword,
              });
            }}
          >
            <FormField label="Mat khau moi" htmlFor="new-password" required>
              <input
                id="new-password"
                type="password"
                value={newPassword}
                minLength={6}
                onChange={(event) => setNewPassword(event.target.value)}
                placeholder="Toi thieu 6 ky tu"
              />
            </FormField>
            <div className="form__actions">
              <Button variant="ghost" type="button" onClick={() => setPasswordModal(null)}>
                Huy
              </Button>
              <Button type="submit" isLoading={changePasswordMutation.isPending} disabled={newPassword.length < 6}>
                Cap nhat
              </Button>
            </div>
          </form>
        )}
      </Modal>
    </div>
  );
};

export default UsersPage;

import { useMemo, useState } from 'react';
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import SearchInput from '../../components/common/SearchInput';
import DataTable from '../../components/common/DataTable';
import EmptyState from '../../components/common/EmptyState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import Pagination from '../../components/common/Pagination';
import Modal from '../../components/common/Modal';
import StatusDot from '../../components/common/StatusDot';
import ContactForm, { type ContactFormValues } from '../../components/forms/ContactForm';
import { fetchContacts, updateContact, deleteContact } from '../../api/contacts';
import { fetchStaff } from '../../api/staff';
import type { Contact, Staff } from '../../types';
import { formatDateTime, formatStatus } from '../../utils/format';

const ContactsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editingContact, setEditingContact] = useState<Contact | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['contacts', { page, search }],
    queryFn: () =>
      fetchContacts({
        page,
        search: search || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  const staffQuery = useQuery({
    queryKey: ['staff', 'options'],
    queryFn: () => fetchStaff({ limit: 100 }),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: ContactFormValues }) => updateContact(id, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['contacts'] });
      setEditingContact(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteContact(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['contacts'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;
  const staffOptions: Staff[] = staffQuery.data?.items ?? [];

  const handleDelete = (contact: Contact) => {
    if (window.confirm(`Xoa lien he tu ${contact.name}?`)) {
      deleteMutation.mutate(contact.id_contact);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'name',
        title: 'Nguoi gui',
        render: (contact: Contact) => (
          <div className="table__stack">
            <span>{contact.name}</span>
            <span className="text-muted">{contact.email}</span>
          </div>
        ),
      },
      {
        key: 'subject',
        title: 'Chu de',
        render: (contact: Contact) => contact.subject,
      },
      {
        key: 'date',
        title: 'Ngay gui',
        render: (contact: Contact) => formatDateTime(contact.contact_date),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (contact: Contact) => <StatusDot status={contact.status}>{formatStatus(contact.status)}</StatusDot>,
      },
      {
        key: 'staff',
        title: 'Nhan vien',
        render: (contact: Contact) => contact.staff?.staff_name ?? '--',
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (contact: Contact) => (
          <div className="table-actions">
            <button type="button" title="Cap nhat" onClick={() => setEditingContact(contact)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(contact)}>
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
        title="Lien he tu khach hang"
        description="Theo doi va phan hoi cac yeu cau."
        actions={
          <SearchInput
            placeholder="Tim theo ten, email..."
            onSearch={(value) => {
              setPage(1);
              setSearch(value);
            }}
          />
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc lien he." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co lien he nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(contact) => contact.id_contact} />
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
        open={Boolean(editingContact)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingContact(null);
          }
        }}
        title={editingContact ? `Cap nhat lien he: ${editingContact.subject}` : ''}
      >
        {editingContact && (
          <ContactForm
            staff={staffOptions}
            defaultValues={{
              subject: editingContact.subject,
              message: editingContact.message,
              status: editingContact.status,
              idStaff: editingContact.id_staff ?? undefined,
              reply: editingContact.reply ?? '',
              replyDate: editingContact.reply_date ? editingContact.reply_date.substring(0, 10) : '',
            }}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingContact(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingContact.id_contact,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default ContactsPage;

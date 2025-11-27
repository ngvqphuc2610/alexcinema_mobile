import { useMemo, useState } from 'react';
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import Button from '../../components/common/Button';
import DataTable from '../../components/common/DataTable';
import StatusDot from '../../components/common/StatusDot';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import EmptyState from '../../components/common/EmptyState';
import Modal from '../../components/common/Modal';
import Pagination from '../../components/common/Pagination';
import SearchInput from '../../components/common/SearchInput';
import {
  fetchPayments,
  createPayment,
  updatePayment,
  deletePayment,
  type PaymentPayload,
  type UpdatePaymentPayload,
} from '../../api/payments';
import { fetchPaymentMethods } from '../../api/payment_methods';
import type { Payment, PaymentMethod } from '../../types';
import { formatCurrency, formatDateTime, formatStatus } from '../../utils/format';
import PaymentsForm, { type PaymentFormValues } from '../../components/forms/PaymentsForm';

const toFormValues = (item?: Payment): PaymentFormValues => ({
  idBooking: item?.id_booking ?? undefined,
  idPaymentMethod: item?.id_payment_method ?? undefined,
  paymentMethod: item?.payment_method ?? '',
  amount: item ? Number(item.amount) : 0,
  status: item?.status ?? 'pending',
  transactionId: item?.transaction_id ?? '',
  providerCode: item?.provider_code ?? '',
  providerOrderId: item?.provider_order_id ?? '',
  providerTransId: item?.provider_trans_id ?? '',
  providerReturnCode: item?.provider_return_code ?? '',
  providerReturnMessage: item?.provider_return_message ?? '',
  paymentDate: item?.payment_date ?? '',
  paymentDetails: item?.payment_details ?? '',
});

const PaymentsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState('');
  const [search, setSearch] = useState('');
  const [isCreateOpen, setCreateOpen] = useState(false);
  const [editing, setEditing] = useState<Payment | null>(null);

  const paymentsQuery = useQuery({
    queryKey: ['payments', { page, statusFilter, search }],
    queryFn: () =>
      fetchPayments({
        page,
        status: statusFilter || undefined,
        transactionId: search || undefined,
        bookingCode: search || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  const methodsQuery = useQuery({
    queryKey: ['payment-methods', { includeInactive: true }],
    queryFn: () => fetchPaymentMethods({ includeInactive: true }),
  });

  const createMutation = useMutation({
    mutationFn: (values: PaymentPayload) => createPayment(values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['payments'] });
      setCreateOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: UpdatePaymentPayload }) =>
      updatePayment(id, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['payments'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deletePayment(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['payments'] }),
  });

  const items = paymentsQuery.data?.items ?? [];
  const meta = paymentsQuery.data?.meta;
  const methods = methodsQuery.data ?? [];

  const columns = useMemo(
    () => [
      {
        key: 'booking',
        title: 'Don',
        render: (item: Payment) => item.booking?.booking_code ?? item.id_booking ?? '--',
      },
      {
        key: 'method',
        title: 'Phuong thuc',
        render: (item: Payment) => item.method?.name ?? item.payment_method ?? '--',
      },
      {
        key: 'amount',
        title: 'So tien',
        render: (item: Payment) => formatCurrency(item.amount),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (item: Payment) => <StatusDot status={item.status}>{formatStatus(item.status)}</StatusDot>,
      },
      {
        key: 'transaction',
        title: 'Ma giao dich',
        render: (item: Payment) => item.transaction_id ?? '--',
      },
      {
        key: 'date',
        title: 'Ngay thanh toan',
        render: (item: Payment) => formatDateTime(item.payment_date),
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (item: Payment) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditing(item)}>
              <Pencil size={16} />
            </button>
            <button
              type="button"
              title="Xoa"
              className="danger"
              onClick={() => {
                if (window.confirm(`Xoa giao dich ${item.transaction_id ?? item.id_payment}?`)) {
                  deleteMutation.mutate(item.id_payment);
                }
              }}
            >
              <Trash2 size={16} />
            </button>
          </div>
        ),
      },
    ],
    [deleteMutation],
  );

  return (
    <div className="page">
      <Card
        title="Giao dich thanh toan"
        description="Theo doi va cap nhat cac giao dich."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim theo ma giao dich / ma don"
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <select
              value={statusFilter}
              onChange={(event) => {
                setPage(1);
                setStatusFilter(event.target.value);
              }}
            >
              <option value="">Tat ca trang thai</option>
              <option value="pending">Dang xu ly</option>
              <option value="success">Thanh cong</option>
              <option value="failed">That bai</option>
            </select>
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateOpen(true)}>
              Them giao dich
            </Button>
          </div>
        }
      >
        {(paymentsQuery.isLoading || methodsQuery.isLoading) && <LoadingOverlay />}
        {paymentsQuery.isError && (
          <ErrorState description="Khong tai duoc danh sach thanh toan." onRetry={() => paymentsQuery.refetch()} />
        )}
        {!paymentsQuery.isLoading && items.length === 0 && <EmptyState description="Chua co giao dich nao." />}
        {!paymentsQuery.isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(item) => item.id_payment} />
            {meta && (
              <Pagination
                page={meta.page}
                totalPages={meta.totalPages}
                total={meta.total}
                onChange={(next) => setPage(next)}
              />
            )}
          </>
        )}
      </Card>

      <Modal open={isCreateOpen} onClose={() => setCreateOpen(false)} title="Them giao dich">
        <PaymentsForm
          paymentMethods={methods as PaymentMethod[]}
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateOpen(false)}
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
        title={editing ? `Chinh sua giao dich ${editing.transaction_id ?? editing.id_payment}` : ''}
      >
        {editing && (
          <PaymentsForm
            paymentMethods={methods as PaymentMethod[]}
            defaultValues={toFormValues(editing)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditing(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editing.id_payment,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default PaymentsPage;

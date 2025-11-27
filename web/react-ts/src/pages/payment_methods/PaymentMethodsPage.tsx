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
import SearchInput from '../../components/common/SearchInput';
import {
  fetchPaymentMethods,
  createPaymentMethod,
  updatePaymentMethod,
  deletePaymentMethod,
  type PaymentMethodPayload,
} from '../../api/payment_methods';
import type { PaymentMethod } from '../../types';
import { formatCurrency } from '../../utils/format';
import PaymentMethodsForm, { type PaymentMethodFormValues } from '../../components/forms/PaymentMethodsForm';

const toFormValues = (item?: PaymentMethod): PaymentMethodFormValues => ({
  methodCode: item?.code ?? '',
  methodName: item?.name ?? '',
  description: item?.description ?? '',
  iconUrl: item?.iconUrl ?? '',
  isActive: item?.isActive ?? true,
  processingFee: item?.processingFee ?? undefined,
  minAmount: item?.minAmount ?? undefined,
  maxAmount: item?.maxAmount ?? undefined,
  displayOrder: item?.displayOrder ?? 0,
});

const PaymentMethodsPage = () => {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [includeInactive, setIncludeInactive] = useState(true);
  const [isCreateOpen, setCreateOpen] = useState(false);
  const [editing, setEditing] = useState<PaymentMethod | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['payment-methods', { includeInactive }],
    queryFn: () => fetchPaymentMethods({ includeInactive }),
    placeholderData: keepPreviousData,
  });

  const createMutation = useMutation({
    mutationFn: (values: PaymentMethodPayload) => createPaymentMethod(values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['payment-methods'] });
      setCreateOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: PaymentMethodPayload }) =>
      updatePaymentMethod(id, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['payment-methods'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deletePaymentMethod(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['payment-methods'] }),
  });

  const items = (data ?? []).filter((item) => {
    if (!search.trim()) return true;
    const keyword = search.trim().toLowerCase();
    return item.code.toLowerCase().includes(keyword) || item.name.toLowerCase().includes(keyword);
  });

  const columns = useMemo(
    () => [
      {
        key: 'icon',
        title: 'Icon',
        render: (item: PaymentMethod) =>
          item.iconUrl ? <img src={item.iconUrl} alt={item.name} className="table-image table-image--square" /> : '--',
      },
      {
        key: 'name',
        title: 'Ten',
        render: (item: PaymentMethod) => item.name,
      },
      {
        key: 'code',
        title: 'Ma',
        render: (item: PaymentMethod) => item.code,
      },
      {
        key: 'fee',
        title: 'Phi',
        render: (item: PaymentMethod) => formatCurrency(item.processingFee ?? 0),
      },
      {
        key: 'limit',
        title: 'Gioi han',
        render: (item: PaymentMethod) => (
          <div className="table-multi">
            <span>Min: {item.minAmount !== null && item.minAmount !== undefined ? formatCurrency(item.minAmount) : '--'}</span>
            <span>Max: {item.maxAmount !== null && item.maxAmount !== undefined ? formatCurrency(item.maxAmount) : '--'}</span>
          </div>
        ),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (item: PaymentMethod) => (
          <StatusDot status={item.isActive ? 'active' : 'inactive'}>
            {item.isActive ? 'Dang kich hoat' : 'Tam dung'}
          </StatusDot>
        ),
      },
      {
        key: 'display',
        title: 'Thu tu',
        render: (item: PaymentMethod) => item.displayOrder ?? 0,
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (item: PaymentMethod) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditing(item)}>
              <Pencil size={16} />
            </button>
            <button
              type="button"
              title="Xoa"
              className="danger"
              onClick={() => {
                if (window.confirm(`Xoa phuong thuc ${item.name}?`)) {
                  deleteMutation.mutate(item.id);
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
        title="Phuong thuc thanh toan"
        description="Quan ly danh sach phuong thuc thanh toan."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim theo ma/ten..."
              onSearch={(value) => {
                setSearch(value);
              }}
            />
            <label className="checkbox">
              <input
                type="checkbox"
                checked={includeInactive}
                onChange={(event) => setIncludeInactive(event.target.checked)}
              />
              <span>Hien ca da tat</span>
            </label>
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateOpen(true)}>
              Them phuong thuc
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach phuong thuc." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co phuong thuc nao." />}
        {!isLoading && items.length > 0 && (
          <DataTable data={items} columns={columns} rowKey={(item) => item.id} />
        )}
      </Card>

      <Modal open={isCreateOpen} onClose={() => setCreateOpen(false)} title="Them phuong thuc thanh toan">
        <PaymentMethodsForm
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
        title={editing ? `Chinh sua ${editing.name}` : ''}
      >
        {editing && (
          <PaymentMethodsForm
            defaultValues={toFormValues(editing)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditing(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editing.id,
                values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default PaymentMethodsPage;

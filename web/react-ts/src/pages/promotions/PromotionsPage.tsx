import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import SearchInput from '../../components/common/SearchInput';
import Pagination from '../../components/common/Pagination';
import Button from '../../components/common/Button';
import EmptyState from '../../components/common/EmptyState';
import ErrorState from '../../components/common/ErrorState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import Modal from '../../components/common/Modal';
import StatusDot from '../../components/common/StatusDot';
import PromotionForm from '../../components/forms/PromotionForm';
import { fetchPromotions, createPromotion, updatePromotion, deletePromotion } from '../../api/promotions';
import { uploadImage } from '../../api/uploads';
import type { Promotion } from '../../types';
import { formatCurrency, formatDateTime, formatStatus } from '../../utils/format';

const mapPromotionToFormValues = (promotion: Promotion) => ({
  promotionCode: promotion.promotion_code,
  title: promotion.title,
  description: promotion.description ?? '',
  image: promotion.image ?? '',
  discountPercent: promotion.discount_percent ? Number(promotion.discount_percent) : undefined,
  discountAmount: promotion.discount_amount ? Number(promotion.discount_amount) : undefined,
  startDate: promotion.start_date.substring(0, 10),
  endDate: promotion.end_date ? promotion.end_date.substring(0, 10) : '',
  minPurchase: promotion.min_purchase ? Number(promotion.min_purchase) : undefined,
  maxDiscount: promotion.max_discount ? Number(promotion.max_discount) : undefined,
  usageLimit: promotion.usage_limit ?? undefined,
  status: promotion.status ?? '',
});

const PromotionsPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editingPromotion, setEditingPromotion] = useState<Promotion | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['promotions', { page, search }],
    queryFn: () => fetchPromotions({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const createMutation = useMutation({
    mutationFn: createPromotion,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['promotions'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: (payload: { id: number; data: Parameters<typeof createPromotion>[0] }) =>
      updatePromotion(payload.id, payload.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['promotions'] });
      setEditingPromotion(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deletePromotion(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['promotions'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (promotion: Promotion) => {
    if (window.confirm('Ban chac chan muon xoa khuyen mai nay?')) {
      deleteMutation.mutate(promotion.id_promotions);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'code',
        title: 'Ma',
        render: (promotion: Promotion) => promotion.promotion_code,
      },
      {
        key: 'image',
        title: 'Anh',
        render: (promotion: Promotion) =>
          promotion.image ? <img src={promotion.image} alt={promotion.title} style={{ height: 40 }} /> : '--',
      },
      {
        key: 'title',
        title: 'Tieu de',
        render: (promotion: Promotion) => promotion.title,
      },
      {
        key: 'start',
        title: 'Bat dau',
        render: (promotion: Promotion) => formatDateTime(promotion.start_date),
      },
      {
        key: 'end',
        title: 'Ket thuc',
        render: (promotion: Promotion) => (promotion.end_date ? formatDateTime(promotion.end_date) : '--'),
      },
      {
        key: 'discount',
        title: 'Giam gia',
        render: (promotion: Promotion) =>
          promotion.discount_percent && promotion.discount_amount
            ? `${promotion.discount_percent}% / ${formatCurrency(promotion.discount_amount)}`
            : promotion.discount_percent
            ? `${promotion.discount_percent}%`
            : formatCurrency(promotion.discount_amount),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (promotion: Promotion) => (
          <StatusDot status={promotion.status}>{formatStatus(promotion.status)}</StatusDot>
        ),
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (promotion: Promotion) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingPromotion(promotion)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(promotion)}>
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
        title="Quan ly khuyen mai"
        description="Tao moi, cap nhat va giam sat chuong trinh khuyen mai."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim theo ma hoac ten khuyen mai..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)}>
              Them khuyen mai
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach khuyen mai." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co khuyen mai nao." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(item) => item.id_promotions} />
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

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them khuyen mai">
        <PromotionForm
          isSubmitting={createMutation.isPending}
          onUploadImage={async (file) => (await uploadImage(file)).url}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) =>
            createMutation.mutate({
              promotionCode: values.promotionCode,
              title: values.title,
              description: values.description,
              image: values.image,
              discountPercent: values.discountPercent,
              discountAmount: values.discountAmount,
              startDate: values.startDate,
              endDate: values.endDate || undefined,
              minPurchase: values.minPurchase,
              maxDiscount: values.maxDiscount,
              usageLimit: values.usageLimit,
              status: values.status,
            })
          }
        />
      </Modal>

      <Modal
        open={Boolean(editingPromotion)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingPromotion(null);
          }
        }}
        title={editingPromotion ? `Chinh sua: ${editingPromotion.title}` : ''}
      >
        {editingPromotion && (
          <PromotionForm
            defaultValues={mapPromotionToFormValues(editingPromotion)}
            isSubmitting={updateMutation.isPending}
            onUploadImage={async (file) => (await uploadImage(file)).url}
            onCancel={() => setEditingPromotion(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingPromotion.id_promotions,
                data: {
                  promotionCode: values.promotionCode,
                  title: values.title,
                  description: values.description,
                  image: values.image,
                  discountPercent: values.discountPercent,
                  discountAmount: values.discountAmount,
                  startDate: values.startDate,
                  endDate: values.endDate || undefined,
                  minPurchase: values.minPurchase,
                  maxDiscount: values.maxDiscount,
                  usageLimit: values.usageLimit,
                  status: values.status,
                },
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default PromotionsPage;

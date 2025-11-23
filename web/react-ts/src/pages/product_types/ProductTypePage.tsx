import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import EmptyState from '../../components/common/EmptyState';
import Modal from '../../components/common/Modal';
import Button from '../../components/common/Button';
import FormField from '../../components/forms/FormField';
import { createTypeProduct, deleteTypeProduct, fetchTypeProducts, updateTypeProduct, type TypeProduct } from '../../api/typeProducts';

interface TypeProductFormValues {
  typeName: string;
  description: string;
}

const toFormValues = (item?: TypeProduct): TypeProductFormValues => ({
  typeName: item?.name ?? '',
  description: item?.description ?? '',
});

const ProductTypePage = () => {
  const queryClient = useQueryClient();
  const [isCreateOpen, setCreateOpen] = useState(false);
  const [editing, setEditing] = useState<TypeProduct | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['type-products'],
    queryFn: fetchTypeProducts,
  });

  const createMutation = useMutation({
    mutationFn: (values: TypeProductFormValues) => createTypeProduct(values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['type-products'] });
      setCreateOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: TypeProductFormValues }) =>
      updateTypeProduct(id, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['type-products'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteTypeProduct(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['type-products'] }),
  });

  const columns = useMemo(
    () => [
      {
        key: 'name',
        title: 'Tên loại',
        render: (item: TypeProduct) => item.name,
      },
      {
        key: 'description',
        title: 'Mô tả',
        render: (item: TypeProduct) => item.description ?? '--',
      },
      {
        key: 'actions',
        title: 'Thao tác',
        render: (item: TypeProduct) => (
          <div className="table-actions">
            <button type="button" title="Chỉnh sửa" onClick={() => setEditing(item)}>
              <Pencil size={16} />
            </button>
            <button
              type="button"
              title="Xóa"
              className="danger"
              onClick={() => {
                if (window.confirm(`Xóa loại sản phẩm "${item.name}"?`)) {
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

  const items = data ?? [];

  return (
    <div className="page">
      <Card
        title="Loại sản phẩm"
        description="Quản lý danh mục loại sản phẩm."
        actions={
          <Button leftIcon={<Plus size={16} />} onClick={() => setCreateOpen(true)}>
            Thêm loại
          </Button>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Không tải được danh sách loại sản phẩm." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chưa có loại sản phẩm nào." />}
        {!isLoading && items.length > 0 && <DataTable data={items} columns={columns} rowKey={(item) => item.id} />}
      </Card>

      <Modal open={isCreateOpen} onClose={() => setCreateOpen(false)} title="Thêm loại sản phẩm">
        <TypeProductForm
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
        title={editing ? `Chỉnh sửa: ${editing.name}` : ''}
      >
        {editing && (
          <TypeProductForm
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

interface TypeProductFormProps {
  defaultValues?: TypeProductFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: TypeProductFormValues) => void;
  onCancel: () => void;
}

const TypeProductForm = ({ defaultValues, isSubmitting, onSubmit, onCancel }: TypeProductFormProps) => {
  const [values, setValues] = useState<TypeProductFormValues>(
    defaultValues ?? {
      typeName: '',
      description: '',
    },
  );

  const handleChange = (field: keyof TypeProductFormValues, value: string) => {
    setValues((prev) => ({ ...prev, [field]: value }));
  };

  return (
    <form
      className="form"
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit(values);
      }}
    >
      <FormField label="Tên loại" htmlFor="type-name" required>
        <input
          id="type-name"
          value={values.typeName}
          required
          maxLength={100}
          onChange={(event) => handleChange('typeName', event.target.value)}
        />
      </FormField>
      <FormField label="Mô tả" htmlFor="type-desc">
        <textarea
          id="type-desc"
          value={values.description}
          onChange={(event) => handleChange('description', event.target.value)}
        />
      </FormField>
      <div className="form__actions">
        <Button type="button" variant="ghost" onClick={onCancel} disabled={isSubmitting}>
          Hủy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          Lưu
        </Button>
      </div>
    </form>
  );
};

export default ProductTypePage;

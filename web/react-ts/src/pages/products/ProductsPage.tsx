import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Pencil, Trash2, Upload } from 'lucide-react';
import Card from '../../components/common/Card';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import EmptyState from '../../components/common/EmptyState';
import Modal from '../../components/common/Modal';
import Button from '../../components/common/Button';
import FormField from '../../components/forms/FormField';
import {
  fetchProducts,
  type ProductCategory,
  type Product,
  createProduct,
  updateProduct,
  deleteProduct,
  type ProductPayload,
} from '../../api/products';
import { uploadImage } from '../../api/uploads';
import { fetchTypeProducts, type TypeProduct } from '../../api/typeProducts';
import '../../index.css';

interface ProductImageOverride {
  [productId: number]: string;
}

interface ProductFormValues {
  typeId: number;
  name: string;
  description: string;
  price: number;
  image?: string;
  status?: string;
  quantity?: number;
}

const toPayload = (values: ProductFormValues): ProductPayload => ({
  idTypeProduct: values.typeId,
  name: values.name,
  description: values.description || undefined,
  price: values.price,
  image: values.image || undefined,
  status: values.status || undefined,
  quantity: values.quantity || undefined,
});

const toFormValues = (product: Product): ProductFormValues => ({
  typeId: product.typeId,
  name: product.name,
  description: product.description ?? '',
  price: product.price,
  image: product.image ?? '',
  status: product.status ?? '',
  quantity: product.quantity ?? undefined,
});

const ProductsPage = () => {
  const queryClient = useQueryClient();
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['products'],
    queryFn: fetchProducts,
  });
  const typeQuery = useQuery({
    queryKey: ['type-products', 'options'],
    queryFn: fetchTypeProducts,
  });

  const [uploadingId, setUploadingId] = useState<number | null>(null);
  const [overrides, setOverrides] = useState<ProductImageOverride>({});
  const [isCreateOpen, setCreateOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);

  const categories = useMemo(() => data ?? [], [data]);

  const createMutation = useMutation({
    mutationFn: (values: ProductFormValues) => createProduct(toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      setCreateOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, values }: { id: number; values: ProductFormValues }) => updateProduct(id, toPayload(values)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      setEditing(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteProduct(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['products'] }),
  });

  const handleUpload = async (product: Product, file: File) => {
    setUploadingId(product.id);
    try {
      const result = await uploadImage(file);
      setOverrides((prev) => ({ ...prev, [product.id]: result.url }));
    } catch (error) {
      console.error('Upload failed', error);
      window.alert('Tải ảnh thất bại, vui lòng thử lại.');
    } finally {
      setUploadingId(null);
    }
  };

  const resolveImage = (product: Product) => overrides[product.id] ?? product.image ?? '';

  if (isLoading) {
    return (
      <div className="page">
        <Card title="Sản phẩm" description="Đang tải danh sách sản phẩm...">
          <LoadingOverlay />
        </Card>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="page">
        <Card title="Sản phẩm">
          <ErrorState description="Không tải được danh sách sản phẩm." onRetry={() => refetch()} />
        </Card>
      </div>
    );
  }

  return (
    <div className="page">
      <Card
        title="Sản phẩm"
        description="Danh sách sản phẩm theo danh mục."
        actions={
          <Button leftIcon={<Plus size={16} />} onClick={() => setCreateOpen(true)}>
            Thêm sản phẩm
          </Button>
        }
      >
        {categories.length === 0 && <p>Chưa có sản phẩm.</p>}
        <div className="product-grid">
          {categories.map((category) => (
            <div key={category.id} className="product-category">
              <h3 className="product-category__title">{category.name}</h3>
              {category.description && <p className="product-category__desc">{category.description}</p>}

              <div className="product-list">
                {category.products.map((product) => (
                  <div key={product.id} className="product-card">
                    <div className="product-card__image">
                      {resolveImage(product) ? (
                        <img src={resolveImage(product)} alt={product.name} />
                      ) : (
                        <div className="product-card__placeholder">No image</div>
                      )}
                    </div>
                    <div className="product-card__content">
                      <div className="product-card__header">
                        <h4 className="product-card__name">{product.name}</h4>
                        <div className="product-card__actions">
                          <button type="button" className="product-action" title="Sửa" onClick={() => setEditing(product)}>
                            <Pencil size={14} />
                          </button>
                          <button
                            type="button"
                            className="product-action product-action--danger"
                            title="Xóa"
                            onClick={() => {
                              if (window.confirm(`Bạn chắc chắn muốn xóa sản phẩm "${product.name}"?`)) {
                                deleteMutation.mutate(product.id);
                              }
                            }}
                          >
                            <Trash2 size={14} />
                          </button>
                        </div>
                      </div>
                      {product.description && <p className="product-card__desc">{product.description}</p>}
                      <div className="product-card__meta">
                        <span className="product-card__price">
                          {Number(product.price).toLocaleString('vi-VN')} đ
                        </span>
                        {product.status && <span className="product-card__status">{product.status}</span>}
                      </div>
                      <div className="product-card__upload">
                        <label className="upload-button">
                          <input
                            type="file"
                            accept="image/*"
                            onChange={(event) => {
                              const file = event.target.files?.[0];
                              if (file) {
                                handleUpload(product, file);
                                event.target.value = '';
                              }
                            }}
                            disabled={uploadingId === product.id}
                            hidden
                          />
                          <Upload size={14} />
                          {uploadingId === product.id ? 'Đang tải...' : 'Tải ảnh mới'}
                        </label>
                        {overrides[product.id] && (
                          <small className="text-muted">Ảnh mới đã tải lên (chưa lưu vào sản phẩm).</small>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Card>

      <Modal open={isCreateOpen} onClose={() => setCreateOpen(false)} title="Thêm sản phẩm">
        <ProductForm
          typeOptions={typeQuery.data ?? []}
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
          <ProductForm
            defaultValues={toFormValues(editing)}
            typeOptions={typeQuery.data ?? []}
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

interface ProductFormProps {
  defaultValues?: ProductFormValues;
  typeOptions: TypeProduct[];
  isSubmitting?: boolean;
  onSubmit: (values: ProductFormValues) => void;
  onCancel: () => void;
}

const ProductForm = ({ defaultValues, typeOptions, isSubmitting, onSubmit, onCancel }: ProductFormProps) => {
  const [values, setValues] = useState<ProductFormValues>(
    defaultValues ?? {
      typeId: typeOptions[0]?.id ?? 0,
      name: '',
      description: '',
      price: 0,
      image: '',
      status: '',
      quantity: undefined,
    },
  );
  const [uploading, setUploading] = useState(false);

  const handleChange = (field: keyof ProductFormValues, value: string | number | undefined) => {
    setValues((prev) => ({ ...prev, [field]: value }));
  };

  const handleUpload = async (file?: File | null) => {
    if (!file) return;
    setUploading(true);
    try {
      const result = await uploadImage(file);
      setValues((prev) => ({ ...prev, image: result.url }));
    } catch (error) {
      console.error('Upload failed', error);
      window.alert('Tải ảnh thất bại, vui lòng thử lại.');
    } finally {
      setUploading(false);
    }
  };

  return (
    <form
      className="form"
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit(values);
      }}
    >
      <FormField label="Loại sản phẩm" htmlFor="product-type" required>
        <select
          id="product-type"
          value={values.typeId}
          onChange={(event) => handleChange('typeId', Number(event.target.value))}
        >
          {typeOptions.map((type) => (
            <option key={type.id} value={type.id}>
              {type.name}
            </option>
          ))}
        </select>
      </FormField>
      <FormField label="Tên sản phẩm" htmlFor="product-name" required>
        <input
          id="product-name"
          value={values.name}
          required
          maxLength={255}
          onChange={(event) => handleChange('name', event.target.value)}
        />
      </FormField>
      <FormField label="Mô tả" htmlFor="product-desc">
        <textarea
          id="product-desc"
          value={values.description}
          onChange={(event) => handleChange('description', event.target.value)}
        />
      </FormField>
      <FormField label="Giá" htmlFor="product-price" required>
        <input
          id="product-price"
          type="number"
          min={0}
          value={values.price}
          onChange={(event) => handleChange('price', Number(event.target.value))}
          required
        />
      </FormField>
      <FormField label="Tồn kho" htmlFor="product-quantity">
        <input
          id="product-quantity"
          type="number"
          min={0}
          value={values.quantity ?? 0}
          onChange={(event) => handleChange('quantity', Number(event.target.value))}
        />
      </FormField>
      <FormField label="Trạng thái" htmlFor="product-status">
        <input
          id="product-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        />
      </FormField>
      <FormField label="Ảnh" htmlFor="product-image">
        <input
          id="product-image"
          value={values.image ?? ''}
          onChange={(event) => handleChange('image', event.target.value)}
        />
        <label className="upload-button" style={{ marginTop: 6 }}>
          <input
            type="file"
            accept="image/*"
            hidden
            onChange={(event) => {
              const file = event.target.files?.[0];
              handleUpload(file);
              event.target.value = '';
            }}
            disabled={uploading}
          />
          <Upload size={14} />
          {uploading ? 'Đang tải...' : 'Tải ảnh'}
        </label>
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

export default ProductsPage;

import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';

const schema = z.object({
  promotionCode: z.string().min(1, 'Nhap ma khuyen mai').max(20, 'Toi da 20 ky tu'),
  title: z.string().min(1, 'Nhap tieu de').max(100, 'Toi da 100 ky tu'),
  description: z.string().optional().or(z.literal('')),
  discountPercent: z.coerce.number().min(0).optional(),
  discountAmount: z.coerce.number().min(0).optional(),
  startDate: z.string().min(1, 'Chon ngay ap dung'),
  endDate: z.string().optional().or(z.literal('')),
  minPurchase: z.coerce.number().min(0).optional(),
  maxDiscount: z.coerce.number().min(0).optional(),
  usageLimit: z.coerce.number().min(0).optional(),
  status: z.string().optional().or(z.literal('')),
});

export type PromotionFormValues = z.infer<typeof schema>;

export interface PromotionFormProps {
  defaultValues?: Partial<PromotionFormValues>;
  onSubmit: (values: PromotionFormValues) => Promise<void> | void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

const normalize = (values: PromotionFormValues) => ({
  ...values,
  promotionCode: values.promotionCode.trim(),
  title: values.title.trim(),
  description: values.description?.trim() || undefined,
  endDate: values.endDate?.trim() || undefined,
  status: values.status?.trim() || undefined,
  discountPercent:
    values.discountPercent !== undefined && !Number.isNaN(values.discountPercent)
      ? values.discountPercent
      : undefined,
  discountAmount:
    values.discountAmount !== undefined && !Number.isNaN(values.discountAmount) ? values.discountAmount : undefined,
  minPurchase:
    values.minPurchase !== undefined && !Number.isNaN(values.minPurchase) ? values.minPurchase : undefined,
  maxDiscount:
    values.maxDiscount !== undefined && !Number.isNaN(values.maxDiscount) ? values.maxDiscount : undefined,
  usageLimit:
    values.usageLimit !== undefined && !Number.isNaN(values.usageLimit) ? Math.trunc(values.usageLimit) : undefined,
});

const PromotionForm = ({ defaultValues, onSubmit, onCancel, isSubmitting = false }: PromotionFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<PromotionFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      promotionCode: '',
      title: '',
      description: '',
      discountPercent: undefined,
      discountAmount: undefined,
      startDate: '',
      endDate: '',
      minPurchase: undefined,
      maxDiscount: undefined,
      usageLimit: undefined,
      status: 'active',
      ...defaultValues,
    },
  });

  const handleFormSubmit = handleSubmit(async (values) => onSubmit(normalize(values)));

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <div className="form__grid form__grid--two">
        <FormField label="Ma khuyen mai" htmlFor="promotion-code" required error={errors.promotionCode?.message}>
          <input id="promotion-code" {...register('promotionCode')} placeholder="MOVIE50" />
        </FormField>
        <FormField label="Tieu de" htmlFor="promotion-title" required error={errors.title?.message}>
          <input id="promotion-title" {...register('title')} placeholder="Giam 50% ve xem phim" />
        </FormField>
      </div>

      <FormField label="Mo ta" htmlFor="promotion-description" error={errors.description?.message}>
        <textarea
          id="promotion-description"
          {...register('description')}
          rows={3}
          placeholder="Chi tiet chuong trinh khuyen mai"
        />
      </FormField>

      <div className="form__grid form__grid--three">
        <FormField label="Giam (%)" htmlFor="promotion-discountPercent" error={errors.discountPercent?.message}>
          <input id="promotion-discountPercent" type="number" min={0} step="0.01" {...register('discountPercent')} />
        </FormField>
        <FormField label="Giam (VND)" htmlFor="promotion-discountAmount" error={errors.discountAmount?.message}>
          <input id="promotion-discountAmount" type="number" min={0} step="0.01" {...register('discountAmount')} />
        </FormField>
        <FormField label="Don hang toi thieu" htmlFor="promotion-minPurchase" error={errors.minPurchase?.message}>
          <input id="promotion-minPurchase" type="number" min={0} step="0.01" {...register('minPurchase')} />
        </FormField>
      </div>

      <div className="form__grid form__grid--three">
        <FormField label="Ngay bat dau" htmlFor="promotion-startDate" required error={errors.startDate?.message}>
          <input id="promotion-startDate" type="date" {...register('startDate')} />
        </FormField>
        <FormField label="Ngay ket thuc" htmlFor="promotion-endDate" error={errors.endDate?.message}>
          <input id="promotion-endDate" type="date" {...register('endDate')} />
        </FormField>
        <FormField label="So luot su dung" htmlFor="promotion-usageLimit" error={errors.usageLimit?.message}>
          <input id="promotion-usageLimit" type="number" min={0} step={1} {...register('usageLimit')} />
        </FormField>
      </div>

      <FormField label="Trang thai" htmlFor="promotion-status" error={errors.status?.message}>
        <input id="promotion-status" {...register('status')} placeholder="active, expired..." />
      </FormField>

      <div className="form__actions">
        <Button variant="ghost" type="button" onClick={onCancel}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          Luu
        </Button>
      </div>
    </form>
  );
};

export default PromotionForm;


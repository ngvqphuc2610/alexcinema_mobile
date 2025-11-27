import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';

const schema = z.object({
  methodCode: z.string().trim().min(2, 'Nhap ma toi thieu 2 ky tu').max(20, 'Toi da 20 ky tu'),
  methodName: z.string().trim().min(2, 'Nhap ten phuong thuc').max(100, 'Toi da 100 ky tu'),
  description: z.string().optional().or(z.literal('')),
  iconUrl: z.string().url('URL khong hop le').optional().or(z.literal('')),
  isActive: z.coerce.boolean().optional(),
  processingFee: z.coerce.number().min(0).optional(),
  minAmount: z.coerce.number().min(0).optional(),
  maxAmount: z.coerce.number().min(0).optional(),
  displayOrder: z.coerce.number().int().min(0).optional(),
});

export type PaymentMethodFormValues = z.infer<typeof schema>;

export interface PaymentMethodsFormProps {
  defaultValues?: Partial<PaymentMethodFormValues>;
  onSubmit: (values: PaymentMethodFormValues) => Promise<void> | void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

const normalize = (values: PaymentMethodFormValues): PaymentMethodFormValues => ({
  ...values,
  methodCode: values.methodCode.trim().toUpperCase(),
  methodName: values.methodName.trim(),
  description: values.description?.trim() || undefined,
  iconUrl: values.iconUrl?.trim() || undefined,
  isActive: values.isActive ?? true,
  processingFee:
    values.processingFee !== undefined && !Number.isNaN(values.processingFee) ? values.processingFee : undefined,
  minAmount: values.minAmount !== undefined && !Number.isNaN(values.minAmount) ? values.minAmount : undefined,
  maxAmount: values.maxAmount !== undefined && !Number.isNaN(values.maxAmount) ? values.maxAmount : undefined,
  displayOrder:
    values.displayOrder !== undefined && !Number.isNaN(values.displayOrder) ? Math.trunc(values.displayOrder) : undefined,
});

const PaymentMethodsForm = ({
  defaultValues,
  onSubmit,
  onCancel,
  isSubmitting = false,
}: PaymentMethodsFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<PaymentMethodFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      methodCode: '',
      methodName: '',
      description: '',
      iconUrl: '',
      isActive: true,
      processingFee: undefined,
      minAmount: undefined,
      maxAmount: undefined,
      displayOrder: 0,
      ...defaultValues,
    },
  });

  const handleFormSubmit = handleSubmit(async (values) => onSubmit(normalize(values)));

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <div className="form__grid form__grid--two">
        <FormField label="Ma phuong thuc" htmlFor="pm-code" required error={errors.methodCode?.message}>
          <input id="pm-code" {...register('methodCode')} placeholder="ZALOPAY" />
        </FormField>
        <FormField label="Ten phuong thuc" htmlFor="pm-name" required error={errors.methodName?.message}>
          <input id="pm-name" {...register('methodName')} placeholder="ZaloPay" />
        </FormField>
      </div>

      <FormField label="Mo ta" htmlFor="pm-description" error={errors.description?.message}>
        <textarea id="pm-description" rows={3} {...register('description')} placeholder="Mo ta ngan..." />
      </FormField>

      <div className="form__grid form__grid--two">
        <FormField label="Icon URL" htmlFor="pm-icon" error={errors.iconUrl?.message}>
          <input id="pm-icon" {...register('iconUrl')} placeholder="https://..." />
        </FormField>
        <FormField label="Trang thai" htmlFor="pm-active">
          <select id="pm-active" {...register('isActive')}>
            <option value="true">Dang kich hoat</option>
            <option value="false">Tam dung</option>
          </select>
        </FormField>
      </div>

      <div className="form__grid form__grid--three">
        <FormField label="Phi xu ly" htmlFor="pm-fee" error={errors.processingFee?.message}>
          <input id="pm-fee" type="number" min={0} step="0.01" {...register('processingFee')} />
        </FormField>
        <FormField label="So tien toi thieu" htmlFor="pm-min" error={errors.minAmount?.message}>
          <input id="pm-min" type="number" min={0} step="0.01" {...register('minAmount')} />
        </FormField>
        <FormField label="So tien toi da" htmlFor="pm-max" error={errors.maxAmount?.message}>
          <input id="pm-max" type="number" min={0} step="0.01" {...register('maxAmount')} />
        </FormField>
      </div>

      <FormField label="Thu tu hien thi" htmlFor="pm-order" error={errors.displayOrder?.message}>
        <input id="pm-order" type="number" min={0} step={1} {...register('displayOrder')} />
      </FormField>

      <div className="form__actions">
        <Button type="button" variant="ghost" onClick={onCancel} disabled={isSubmitting}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          Luu
        </Button>
      </div>
    </form>
  );
};

export default PaymentMethodsForm;

import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';
import type { PaymentMethod } from '../../types';

const schema = z.object({
  idBooking: z.coerce.number().int().positive().optional(),
  idPaymentMethod: z.coerce.number().int().positive().optional(),
  paymentMethod: z.string().trim().optional(),
  amount: z.coerce.number().positive('So tien phai lon hon 0'),
  status: z.string().trim().min(1, 'Nhap trang thai'),
  transactionId: z.string().trim().optional().or(z.literal('')),
  providerCode: z.string().trim().optional().or(z.literal('')),
  providerOrderId: z.string().trim().optional().or(z.literal('')),
  providerTransId: z.string().trim().optional().or(z.literal('')),
  providerReturnCode: z.string().trim().optional().or(z.literal('')),
  providerReturnMessage: z.string().trim().optional().or(z.literal('')),
  paymentDate: z.string().trim().optional().or(z.literal('')),
  paymentDetails: z.string().trim().optional().or(z.literal('')),
});

export type PaymentFormValues = z.infer<typeof schema>;

export interface PaymentsFormProps {
  paymentMethods?: PaymentMethod[];
  defaultValues?: Partial<PaymentFormValues>;
  onSubmit: (values: PaymentFormValues) => Promise<void> | void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

const normalize = (values: PaymentFormValues): PaymentFormValues => ({
  ...values,
  idBooking: values.idBooking ?? undefined,
  idPaymentMethod: values.idPaymentMethod ?? undefined,
  paymentMethod: values.paymentMethod?.trim() || undefined,
  status: values.status.trim(),
  transactionId: values.transactionId?.trim() || undefined,
  providerCode: values.providerCode?.trim() || undefined,
  providerOrderId: values.providerOrderId?.trim() || undefined,
  providerTransId: values.providerTransId?.trim() || undefined,
  providerReturnCode: values.providerReturnCode?.trim() || undefined,
  providerReturnMessage: values.providerReturnMessage?.trim() || undefined,
  paymentDate: values.paymentDate?.trim() || undefined,
  paymentDetails: values.paymentDetails?.trim() || undefined,
});

const PaymentsForm = ({
  paymentMethods = [],
  defaultValues,
  onSubmit,
  onCancel,
  isSubmitting = false,
}: PaymentsFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<PaymentFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      idBooking: undefined,
      idPaymentMethod: undefined,
      paymentMethod: '',
      amount: 0,
      status: 'pending',
      transactionId: '',
      providerCode: '',
      providerOrderId: '',
      providerTransId: '',
      providerReturnCode: '',
      providerReturnMessage: '',
      paymentDate: '',
      paymentDetails: '',
      ...defaultValues,
    },
  });

  const handleFormSubmit = handleSubmit(async (values) => onSubmit(normalize(values)));

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <div className="form__grid form__grid--two">
        <FormField label="Ma don (booking ID)" htmlFor="payment-booking">
          <input id="payment-booking" type="number" min={1} {...register('idBooking')} placeholder="ID don dat ve" />
        </FormField>
        <FormField label="So tien" htmlFor="payment-amount" required error={errors.amount?.message}>
          <input id="payment-amount" type="number" min={0} step="0.01" {...register('amount')} />
        </FormField>
      </div>

      <div className="form__grid form__grid--two">
        <FormField label="Phuong thuc" htmlFor="payment-method">
          <select id="payment-method" {...register('idPaymentMethod')}>
            <option value="">Chon tu danh sach</option>
            {paymentMethods.map((method) => (
              <option key={method.id} value={method.id}>
                {method.name} ({method.code})
              </option>
            ))}
          </select>
        </FormField>
        <FormField label="Ma phuong thuc (text)" htmlFor="payment-method-text">
          <input
            id="payment-method-text"
            {...register('paymentMethod')}
            placeholder="ZALOPAY / CASH..."
            autoComplete="off"
          />
        </FormField>
      </div>

      <div className="form__grid form__grid--two">
        <FormField label="Trang thai" htmlFor="payment-status" required error={errors.status?.message}>
          <input id="payment-status" {...register('status')} placeholder="pending / success / failed" />
        </FormField>
        <FormField label="Ngay thanh toan" htmlFor="payment-date" error={errors.paymentDate?.message}>
          <input id="payment-date" type="datetime-local" {...register('paymentDate')} />
        </FormField>
      </div>

      <FormField label="Ma giao dich" htmlFor="payment-transaction" error={errors.transactionId?.message}>
        <input id="payment-transaction" {...register('transactionId')} placeholder="Transaction ID" />
      </FormField>

      <div className="form__grid form__grid--two">
        <FormField label="Provider code" htmlFor="payment-providerCode" error={errors.providerCode?.message}>
          <input id="payment-providerCode" {...register('providerCode')} placeholder="ZALOPAY..." />
        </FormField>
        <FormField label="Provider order ID" htmlFor="payment-providerOrder" error={errors.providerOrderId?.message}>
          <input id="payment-providerOrder" {...register('providerOrderId')} placeholder="Order id tu provider" />
        </FormField>
      </div>

      <div className="form__grid form__grid--two">
        <FormField label="Provider trans ID" htmlFor="payment-providerTrans" error={errors.providerTransId?.message}>
          <input id="payment-providerTrans" {...register('providerTransId')} placeholder="Trans id tu provider" />
        </FormField>
        <FormField label="Ma tra ve" htmlFor="payment-returnCode" error={errors.providerReturnCode?.message}>
          <input id="payment-returnCode" {...register('providerReturnCode')} placeholder="Return code" />
        </FormField>
      </div>

      <FormField
        label="Thong diep tra ve"
        htmlFor="payment-returnMessage"
        error={errors.providerReturnMessage?.message}
      >
        <textarea id="payment-returnMessage" rows={2} {...register('providerReturnMessage')} />
      </FormField>

      <FormField label="Chi tiet giao dich" htmlFor="payment-details" error={errors.paymentDetails?.message}>
        <textarea id="payment-details" rows={3} {...register('paymentDetails')} placeholder="JSON hoac noi dung mo ta" />
      </FormField>

      <div className="form__actions">
        <Button type="button" variant="ghost" disabled={isSubmitting} onClick={onCancel}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          Luu
        </Button>
      </div>
    </form>
  );
};

export default PaymentsForm;

import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';

const schema = z.object({
  paymentStatus: z.string().min(1, 'Nhap trang thai thanh toan'),
  bookingStatus: z.string().min(1, 'Nhap trang thai dat ve'),
  bookingCode: z.string().optional().or(z.literal('')),
});

export type BookingStatusFormValues = z.infer<typeof schema>;

export interface BookingStatusFormProps {
  defaultValues: BookingStatusFormValues;
  onSubmit: (values: BookingStatusFormValues) => Promise<void> | void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

const normalize = (values: BookingStatusFormValues) => ({
  paymentStatus: values.paymentStatus.trim(),
  bookingStatus: values.bookingStatus.trim(),
  bookingCode: values.bookingCode?.trim() || undefined,
});

const BookingStatusForm = ({ defaultValues, onSubmit, onCancel, isSubmitting = false }: BookingStatusFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<BookingStatusFormValues>({
    resolver: zodResolver(schema),
    defaultValues,
  });

  const handleFormSubmit = handleSubmit(async (values) => onSubmit(normalize(values)));

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <FormField
        label="Trang thai thanh toan"
        htmlFor="booking-paymentStatus"
        required
        error={errors.paymentStatus?.message}
      >
        <input id="booking-paymentStatus" {...register('paymentStatus')} placeholder="paid, unpaid..." />
      </FormField>

      <FormField
        label="Trang thai dat ve"
        htmlFor="booking-bookingStatus"
        required
        error={errors.bookingStatus?.message}
      >
        <input id="booking-bookingStatus" {...register('bookingStatus')} placeholder="pending, confirmed..." />
      </FormField>

      <FormField label="Ma don" htmlFor="booking-bookingCode" error={errors.bookingCode?.message}>
        <input id="booking-bookingCode" {...register('bookingCode')} placeholder="Ma dat ve (tuy chon)" />
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

export default BookingStatusForm;


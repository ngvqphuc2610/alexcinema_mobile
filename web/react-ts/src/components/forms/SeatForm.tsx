import { useState } from 'react';
import type { Screen } from '../../types';
import FormField from './FormField';
import Button from '../common/Button';

export interface SeatFormValues extends Record<string, unknown> {
  idScreen?: number;
  idSeatType?: number;
  seatRow: string;
  seatNumber: number;
  status?: string;
}

interface SeatFormProps {
  screens: Screen[];
  defaultValues?: SeatFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: SeatFormValues) => void;
  onCancel: () => void;
}

const SeatForm = ({ screens, defaultValues, isSubmitting, onSubmit, onCancel }: SeatFormProps) => {
  const [values, setValues] = useState<SeatFormValues>(
    defaultValues ?? {
      idScreen: screens[0]?.id_screen,
      idSeatType: undefined,
      seatRow: '',
      seatNumber: 1,
      status: 'active',
    },
  );

  const handleChange = (field: keyof SeatFormValues, value: string) => {
    if (field === 'seatNumber') {
      setValues((prev) => ({ ...prev, seatNumber: Number(value) || 0 }));
      return;
    }
    if (field === 'idScreen' || field === 'idSeatType') {
      setValues((prev) => ({ ...prev, [field]: value ? Number(value) : undefined }));
      return;
    }
    setValues((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();

    // Validation
    if (!values.idScreen) {
      alert('Vui long chon phong chieu');
      return;
    }
    if (!values.idSeatType) {
      alert('Vui long chon loai ghe');
      return;
    }
    if (!values.seatRow || values.seatRow.trim() === '') {
      alert('Vui long nhap hang ghe');
      return;
    }
    if (!values.seatNumber || values.seatNumber < 1) {
      alert('So ghe phai lon hon 0');
      return;
    }

    onSubmit(values);
  };

  return (
    <form className="form" onSubmit={handleSubmit}>
      <FormField label="Phong chieu" htmlFor="seat-screen" required>
        <select
          id="seat-screen"
          value={values.idScreen ?? ''}
          onChange={(event) => handleChange('idScreen', event.target.value)}
          required
        >
          <option value="">-- Chon phong --</option>
          {screens.map((screen) => (
            <option key={screen.id_screen} value={screen.id_screen}>
              {screen.screen_name}
            </option>
          ))}
        </select>
      </FormField>
      <FormField label="Loai ghe" htmlFor="seat-type" required>
        <select
          id="seat-type"
          value={values.idSeatType ?? ''}
          onChange={(event) => handleChange('idSeatType', event.target.value)}
          required
        >
          <option value="">-- Chon loai ghe --</option>
          <option value="1">VIP</option>
          <option value="2">Standard</option>
          <option value="3">Economy</option>
        </select>
      </FormField>
      <FormField label="Hang ghe" htmlFor="seat-row" required>
        <input
          id="seat-row"
          value={values.seatRow}
          required
          maxLength={2}
          onChange={(event) => handleChange('seatRow', event.target.value.toUpperCase())}
        />
      </FormField>
      <FormField label="So ghe" htmlFor="seat-number" required>
        <input
          id="seat-number"
          type="number"
          min={1}
          value={values.seatNumber}
          onChange={(event) => handleChange('seatNumber', event.target.value)}
          required
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="seat-status">
        <select
          id="seat-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Hoat dong</option>
          <option value="inactive">Tam ngung</option>
          <option value="maintenance">Bao tri</option>
        </select>
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

export default SeatForm;

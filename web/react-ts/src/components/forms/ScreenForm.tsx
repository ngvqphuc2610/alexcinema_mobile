import { useState } from 'react';
import type { Cinema } from '../../types';
import FormField from './FormField';
import Button from '../common/Button';

export interface ScreenFormValues {
  idCinema?: number;
  screenName: string;
  capacity: number;
  status?: string;
  idScreenType?: number;
}

interface ScreenFormProps {
  cinemas: Cinema[];
  defaultValues?: ScreenFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: ScreenFormValues) => void;
  onCancel: () => void;
}

const ScreenForm = ({ cinemas, defaultValues, isSubmitting, onSubmit, onCancel }: ScreenFormProps) => {
  const [values, setValues] = useState<ScreenFormValues>(
    defaultValues ?? {
      idCinema: cinemas[0]?.id_cinema,
      screenName: '',
      capacity: 50,
      status: 'active',
      idScreenType: undefined,
    },
  );

  const handleChange = (field: keyof ScreenFormValues, value: string) => {
    if (field === 'capacity') {
      setValues((prev) => ({ ...prev, capacity: Number(value) || 0 }));
      return;
    }
    if (field === 'idCinema' || field === 'idScreenType') {
      setValues((prev) => ({ ...prev, [field]: value ? Number(value) : undefined }));
      return;
    }
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
      <FormField label="Rap" htmlFor="screen-cinema">
        <select
          id="screen-cinema"
          value={values.idCinema ?? ''}
          onChange={(event) => handleChange('idCinema', event.target.value)}
        >
          <option value="">-- Chon rap --</option>
          {cinemas.map((cinema) => (
            <option key={cinema.id_cinema} value={cinema.id_cinema}>
              {cinema.cinema_name}
            </option>
          ))}
        </select>
      </FormField>
      <FormField label="Ten phong" htmlFor="screen-name" required>
        <input
          id="screen-name"
          value={values.screenName}
          required
          maxLength={50}
          onChange={(event) => handleChange('screenName', event.target.value)}
        />
      </FormField>
      <FormField label="Suc chua" htmlFor="screen-capacity" required>
        <input
          id="screen-capacity"
          type="number"
          min={1}
          value={values.capacity}
          onChange={(event) => handleChange('capacity', event.target.value)}
          required
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="screen-status">
        <select
          id="screen-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="">Khac</option>
        </select>
      </FormField>
      <FormField label="ID loai phong" htmlFor="screen-type">
        <input
          id="screen-type"
          type="number"
          value={values.idScreenType ?? ''}
          onChange={(event) => handleChange('idScreenType', event.target.value)}
        />
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

export default ScreenForm;


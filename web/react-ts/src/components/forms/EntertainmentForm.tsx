import { useState } from 'react';
import type { Cinema, Staff } from '../../types';
import FormField from './FormField';
import Button from '../common/Button';

export interface EntertainmentFormValues extends Record<string, unknown> {
  idCinema?: number;
  title: string;
  description?: string;
  imageUrl?: string;
  startDate: string;
  endDate?: string;
  status?: string;
  viewsCount?: number;
  featured?: boolean;
  idStaff?: number;
}

interface EntertainmentFormProps {
  cinemas: Cinema[];
  staff: Staff[];
  defaultValues?: EntertainmentFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: EntertainmentFormValues) => void;
  onCancel: () => void;
}

const EntertainmentForm = ({
  cinemas,
  staff,
  defaultValues,
  isSubmitting,
  onSubmit,
  onCancel,
}: EntertainmentFormProps) => {
  const [values, setValues] = useState<EntertainmentFormValues>(
    defaultValues ?? {
      idCinema: cinemas[0]?.id_cinema,
      title: '',
      description: '',
      imageUrl: '',
      startDate: new Date().toISOString().substring(0, 10),
      endDate: '',
      status: 'active',
      viewsCount: 0,
      featured: false,
      idStaff: staff[0]?.id_staff,
    },
  );

  const handleChange = (field: keyof EntertainmentFormValues, value: string | boolean) => {
    if (field === 'viewsCount') {
      setValues((prev) => ({ ...prev, viewsCount: typeof value === 'string' ? Number(value) || 0 : 0 }));
      return;
    }
    if (field === 'featured') {
      setValues((prev) => ({ ...prev, featured: Boolean(value) }));
      return;
    }
    if (field === 'idCinema' || field === 'idStaff') {
      setValues((prev) => ({ ...prev, [field]: typeof value === 'string' && value ? Number(value) : undefined }));
      return;
    }
    setValues((prev) => ({ ...prev, [field]: value as string }));
  };

  return (
    <form
      className="form"
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit(values);
      }}
    >
      <FormField label="Rap" htmlFor="entertainment-cinema">
        <select
          id="entertainment-cinema"
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
      <FormField label="Tieu de" htmlFor="entertainment-title" required>
        <input
          id="entertainment-title"
          value={values.title}
          required
          maxLength={255}
          onChange={(event) => handleChange('title', event.target.value)}
        />
      </FormField>
      <FormField label="Mo ta" htmlFor="entertainment-description">
        <textarea
          id="entertainment-description"
          value={values.description ?? ''}
          onChange={(event) => handleChange('description', event.target.value)}
        />
      </FormField>
      <FormField label="Hinh anh" htmlFor="entertainment-image">
        <input
          id="entertainment-image"
          value={values.imageUrl ?? ''}
          onChange={(event) => handleChange('imageUrl', event.target.value)}
        />
      </FormField>
      <FormField label="Ngay bat dau" htmlFor="entertainment-start" required>
        <input
          id="entertainment-start"
          type="date"
          value={values.startDate}
          required
          onChange={(event) => handleChange('startDate', event.target.value)}
        />
      </FormField>
      <FormField label="Ngay ket thuc" htmlFor="entertainment-end">
        <input
          id="entertainment-end"
          type="date"
          value={values.endDate ?? ''}
          onChange={(event) => handleChange('endDate', event.target.value)}
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="entertainment-status">
        <select
          id="entertainment-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="draft">Draft</option>
          <option value="">Khac</option>
        </select>
      </FormField>
      <FormField label="Luot xem" htmlFor="entertainment-views">
        <input
          id="entertainment-views"
          type="number"
          min={0}
          value={values.viewsCount ?? 0}
          onChange={(event) => handleChange('viewsCount', event.target.value)}
        />
      </FormField>
      <FormField label="Noi bat" htmlFor="entertainment-featured">
        <input
          id="entertainment-featured"
          type="checkbox"
          checked={values.featured ?? false}
          onChange={(event) => handleChange('featured', event.target.checked)}
        />
      </FormField>
      <FormField label="Nhan vien phu trach" htmlFor="entertainment-staff">
        <select
          id="entertainment-staff"
          value={values.idStaff ?? ''}
          onChange={(event) => handleChange('idStaff', event.target.value)}
        >
          <option value="">-- Khong chon --</option>
          {staff.map((member) => (
            <option key={member.id_staff} value={member.id_staff}>
              {member.staff_name}
            </option>
          ))}
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

export default EntertainmentForm;

import { useState } from 'react';
import type { TypeStaff } from '../../types';
import FormField from './FormField';
import Button from '../common/Button';

export interface StaffFormValues extends Record<string, unknown> {
  idTypeStaff?: number;
  staffName: string;
  email: string;
  password?: string;
  phoneNumber?: string;
  address?: string;
  dateOfBirth?: string;
  hireDate?: string;
  status?: string;
  profileImage?: string;
}

interface StaffFormProps {
  mode: 'create' | 'edit';
  staffTypes: TypeStaff[];
  defaultValues?: StaffFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: StaffFormValues) => void;
  onCancel: () => void;
}

const StaffForm = ({ mode, staffTypes, defaultValues, isSubmitting, onSubmit, onCancel }: StaffFormProps) => {
  const [values, setValues] = useState<StaffFormValues>(
    defaultValues ?? {
      idTypeStaff: staffTypes[0]?.id_typestaff,
      staffName: '',
      email: '',
      password: '',
      phoneNumber: '',
      address: '',
      dateOfBirth: '',
      hireDate: '',
      status: 'active',
      profileImage: '',
    },
  );

  const handleChange = (field: keyof StaffFormValues, value: string) => {
    if (field === 'idTypeStaff') {
      setValues((prev) => ({ ...prev, idTypeStaff: value ? Number(value) : undefined }));
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
      <FormField label="Loai nhan vien" htmlFor="staff-type">
        <select
          id="staff-type"
          value={values.idTypeStaff ?? ''}
          onChange={(event) => handleChange('idTypeStaff', event.target.value)}
        >
          <option value="">-- Khong chon --</option>
          {staffTypes.map((type) => (
            <option key={type.id_typestaff} value={type.id_typestaff}>
              {type.type_name}
            </option>
          ))}
        </select>
      </FormField>
      <FormField label="Ho ten" htmlFor="staff-name" required>
        <input
          id="staff-name"
          value={values.staffName}
          required
          maxLength={100}
          onChange={(event) => handleChange('staffName', event.target.value)}
        />
      </FormField>
      <FormField label="Email" htmlFor="staff-email" required>
        <input
          id="staff-email"
          type="email"
          value={values.email}
          required
          onChange={(event) => handleChange('email', event.target.value)}
        />
      </FormField>
      {mode === 'create' && (
        <FormField label="Mat khau" htmlFor="staff-password" required>
          <input
            id="staff-password"
            type="password"
            minLength={6}
            value={values.password ?? ''}
            required
            onChange={(event) => handleChange('password', event.target.value)}
          />
        </FormField>
      )}
      <FormField label="So dien thoai" htmlFor="staff-phone">
        <input
          id="staff-phone"
          value={values.phoneNumber ?? ''}
          onChange={(event) => handleChange('phoneNumber', event.target.value)}
        />
      </FormField>
      <FormField label="Dia chi" htmlFor="staff-address">
        <input
          id="staff-address"
          value={values.address ?? ''}
          onChange={(event) => handleChange('address', event.target.value)}
        />
      </FormField>
      <FormField label="Ngay sinh" htmlFor="staff-dob">
        <input
          id="staff-dob"
          type="date"
          value={values.dateOfBirth ?? ''}
          onChange={(event) => handleChange('dateOfBirth', event.target.value)}
        />
      </FormField>
      <FormField label="Ngay vao lam" htmlFor="staff-hire-date">
        <input
          id="staff-hire-date"
          type="date"
          value={values.hireDate ?? ''}
          onChange={(event) => handleChange('hireDate', event.target.value)}
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="staff-status">
        <select
          id="staff-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="on leave">Nghi phep</option>
          <option value="">Khac</option>
        </select>
      </FormField>
      <FormField label="Anh dai dien" htmlFor="staff-avatar">
        <input
          id="staff-avatar"
          value={values.profileImage ?? ''}
          onChange={(event) => handleChange('profileImage', event.target.value)}
        />
      </FormField>
      <div className="form__actions">
        <Button type="button" variant="ghost" disabled={isSubmitting} onClick={onCancel}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          {mode === 'create' ? 'Them' : 'Luu'}
        </Button>
      </div>
    </form>
  );
};

export default StaffForm;

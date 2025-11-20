import { useState } from 'react';
import FormField from './FormField';
import Button from '../common/Button';

export interface MemberFormValues extends Record<string, unknown> {
  idUser?: number;
  idTypeMember?: number;
  idMembership?: number;
  points?: number;
  joinDate?: string;
  status?: string;
}

interface MemberFormProps {
  mode: 'create' | 'edit';
  defaultValues?: MemberFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: MemberFormValues) => void;
  onCancel: () => void;
}

const MemberForm = ({ mode, defaultValues, isSubmitting, onSubmit, onCancel }: MemberFormProps) => {
  const [values, setValues] = useState<MemberFormValues>(
    defaultValues ?? {
      idUser: undefined,
      idTypeMember: undefined,
      idMembership: undefined,
      points: 0,
      joinDate: new Date().toISOString().substring(0, 10),
      status: 'active',
    },
  );

  const handleChange = (field: keyof MemberFormValues, value: string) => {
    if (field === 'points') {
      setValues((prev) => ({ ...prev, points: value === '' ? undefined : Number(value) }));
      return;
    }
    if (field === 'idUser' || field === 'idTypeMember' || field === 'idMembership') {
      setValues((prev) => ({ ...prev, [field]: value === '' ? undefined : Number(value) }));
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
      <FormField label="ID nguoi dung" htmlFor="member-user" required={mode === 'create'}>
        <input
          id="member-user"
          type="number"
          value={values.idUser ?? ''}
          required={mode === 'create'}
          onChange={(event) => handleChange('idUser', event.target.value)}
        />
      </FormField>
      <FormField label="ID hang thanh vien" htmlFor="member-type" required={mode === 'create'}>
        <input
          id="member-type"
          type="number"
          value={values.idTypeMember ?? ''}
          required={mode === 'create'}
          onChange={(event) => handleChange('idTypeMember', event.target.value)}
        />
      </FormField>
      <FormField label="ID membership" htmlFor="member-membership">
        <input
          id="member-membership"
          type="number"
          value={values.idMembership ?? ''}
          onChange={(event) => handleChange('idMembership', event.target.value)}
        />
      </FormField>
      <FormField label="Diem tich luy" htmlFor="member-points">
        <input
          id="member-points"
          type="number"
          min={0}
          value={values.points ?? ''}
          onChange={(event) => handleChange('points', event.target.value)}
        />
      </FormField>
      <FormField label="Ngay tham gia" htmlFor="member-join-date">
        <input
          id="member-join-date"
          type="date"
          value={values.joinDate ?? ''}
          onChange={(event) => handleChange('joinDate', event.target.value)}
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="member-status">
        <select
          id="member-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="suspended">Tam khoa</option>
          <option value="">Khac</option>
        </select>
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

export default MemberForm;

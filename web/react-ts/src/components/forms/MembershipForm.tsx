import { useState, type ChangeEvent } from 'react';
import FormField from './FormField';
import Button from '../common/Button';
import { uploadImage } from '../../api/uploads';

export interface MembershipFormValues extends Record<string, unknown> {
  code: string;
  title: string;
  image?: string;
  link?: string;
  description?: string;
  benefits?: string;
  criteria?: string;
  status?: string;
}

interface MembershipFormProps {
  defaultValues?: MembershipFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: MembershipFormValues) => void;
  onCancel: () => void;
}

const MembershipForm = ({ defaultValues, isSubmitting, onSubmit, onCancel }: MembershipFormProps) => {
  const [values, setValues] = useState<MembershipFormValues>(
    defaultValues ?? {
      code: '',
      title: '',
      image: '',
      link: '',
      description: '',
      benefits: '',
      criteria: '',
      status: 'active',
    },
  );
  const [isUploading, setUploading] = useState(false);

  const handleChange = (field: keyof MembershipFormValues, value: string) => {
    setValues((prev) => ({ ...prev, [field]: value }));
  };

  const handleUpload = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setUploading(true);
    try {
      const uploaded = await uploadImage(file);
      setValues((prev) => ({ ...prev, image: uploaded.url }));
    } catch (error) {
      console.error('Upload membership image failed', error);
      window.alert('Tai anh that bai, vui long thu lai.');
    } finally {
      setUploading(false);
      event.target.value = '';
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
      <FormField label="Ma hang" htmlFor="membership-code" required>
        <input
          id="membership-code"
          value={values.code}
          required
          maxLength={50}
          onChange={(event) => handleChange('code', event.target.value)}
        />
      </FormField>
      <FormField label="Ten hang" htmlFor="membership-title" required>
        <input
          id="membership-title"
          value={values.title}
          required
          maxLength={100}
          onChange={(event) => handleChange('title', event.target.value)}
        />
      </FormField>
      <FormField label="Anh dai dien" htmlFor="membership-image">
        <input
          id="membership-image"
          value={values.image ?? ''}
          onChange={(event) => handleChange('image', event.target.value)}
        />
        <input type="file" accept="image/*" onChange={handleUpload} disabled={isUploading} />
        {isUploading && <small className="text-muted">Dang tai anh...</small>}
      </FormField>
      <FormField label="Lien ket" htmlFor="membership-link">
        <input
          id="membership-link"
          value={values.link ?? ''}
          onChange={(event) => handleChange('link', event.target.value)}
        />
      </FormField>
      <FormField label="Mo ta" htmlFor="membership-description">
        <textarea
          id="membership-description"
          value={values.description ?? ''}
          onChange={(event) => handleChange('description', event.target.value)}
        />
      </FormField>
      <FormField label="Quyen loi" htmlFor="membership-benefits">
        <textarea
          id="membership-benefits"
          value={values.benefits ?? ''}
          onChange={(event) => handleChange('benefits', event.target.value)}
        />
      </FormField>
      <FormField label="Dieu kien" htmlFor="membership-criteria">
        <textarea
          id="membership-criteria"
          value={values.criteria ?? ''}
          onChange={(event) => handleChange('criteria', event.target.value)}
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="membership-status">
        <select
          id="membership-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="">Khac</option>
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

export default MembershipForm;

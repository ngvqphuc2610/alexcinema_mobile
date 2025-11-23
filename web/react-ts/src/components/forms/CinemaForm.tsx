import { useState, type ChangeEvent } from 'react';
import FormField from './FormField';
import Button from '../common/Button';
import { uploadImage } from '../../api/uploads';

export interface CinemaFormValues {
  cinemaName: string;
  address: string;
  city: string;
  description?: string;
  image?: string;
  contactNumber?: string;
  email?: string;
  status?: string;
}

interface CinemaFormProps {
  defaultValues?: CinemaFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: CinemaFormValues) => void;
  onCancel: () => void;
}

const CinemaForm = ({ defaultValues, isSubmitting, onSubmit, onCancel }: CinemaFormProps) => {
  const [values, setValues] = useState<CinemaFormValues>(
    defaultValues ?? {
      cinemaName: '',
      address: '',
      city: '',
      description: '',
      image: '',
      contactNumber: '',
      email: '',
      status: 'active',
    },
  );
  const [isUploading, setUploading] = useState(false);

  const handleChange = (field: keyof CinemaFormValues, value: string) => {
    setValues((prev) => ({ ...prev, [field]: value }));
  };

  const handleImageUpload = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }

    setUploading(true);
    try {
      const response = await uploadImage(file);
      setValues((prev) => ({ ...prev, image: response.url }));
    } catch (error) {
      console.error('Failed to upload cinema image', error);
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
      <FormField label="Ten rap" htmlFor="cinema-name" required>
        <input
          id="cinema-name"
          value={values.cinemaName}
          required
          maxLength={100}
          onChange={(event) => handleChange('cinemaName', event.target.value)}
        />
      </FormField>
      <FormField label="Dia chi" htmlFor="cinema-address" required>
        <input
          id="cinema-address"
          value={values.address}
          required
          maxLength={255}
          onChange={(event) => handleChange('address', event.target.value)}
        />
      </FormField>
      <FormField label="Thanh pho" htmlFor="cinema-city" required>
        <input
          id="cinema-city"
          value={values.city}
          required
          maxLength={50}
          onChange={(event) => handleChange('city', event.target.value)}
        />
      </FormField>
      <FormField label="Mo ta" htmlFor="cinema-description">
        <textarea
          id="cinema-description"
          value={values.description ?? ''}
          onChange={(event) => handleChange('description', event.target.value)}
        />
      </FormField>
      <FormField label="Anh dai dien" htmlFor="cinema-image">
        <input
          id="cinema-image"
          value={values.image ?? ''}
          onChange={(event) => handleChange('image', event.target.value)}
        />
        <input type="file" accept="image/*" onChange={handleImageUpload} disabled={isUploading} />
        {isUploading && <small className="text-muted">Dang tai anh...</small>}
      </FormField>
      <FormField label="So dien thoai" htmlFor="cinema-contact">
        <input
          id="cinema-contact"
          value={values.contactNumber ?? ''}
          maxLength={20}
          onChange={(event) => handleChange('contactNumber', event.target.value)}
        />
      </FormField>
      <FormField label="Email" htmlFor="cinema-email">
        <input
          id="cinema-email"
          type="email"
          value={values.email ?? ''}
          onChange={(event) => handleChange('email', event.target.value)}
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="cinema-status">
        <select
          id="cinema-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="">Khac</option>
        </select>
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

export default CinemaForm;

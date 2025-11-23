import { useMemo, useState, type ChangeEvent } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';
import { uploadImage } from '../../api/uploads';

const baseSchema = z.object({
  username: z.string().min(4, 'Toi thieu 4 ky tu').max(50, 'Toi da 50 ky tu'),
  email: z.string().email('Email khong hop le'),
  fullName: z.string().min(2, 'Toi thieu 2 ky tu').max(100, 'Toi da 100 ky tu'),
  password: z
    .string()
    .min(6, 'Mat khau toi thieu 6 ky tu')
    .optional()
    .or(z.literal('')),
  phoneNumber: z.string().max(20, 'Toi da 20 ky tu').optional().or(z.literal('')),
  dateOfBirth: z.string().optional().or(z.literal('')),
  gender: z.string().optional().or(z.literal('')),
  address: z.string().optional().or(z.literal('')),
  profileImage: z.string().optional().or(z.literal('')),
  role: z.enum(['admin', 'user'], { required_error: 'Chon vai tro' }),
  status: z.enum(['active', 'inactive'], { required_error: 'Chon trang thai' }),
});

export type UserFormValues = z.infer<typeof baseSchema>;

export interface UserFormProps {
  defaultValues?: Partial<UserFormValues>;
  onSubmit: (values: UserFormValues) => Promise<void> | void;
  onCancel: () => void;
  mode?: 'create' | 'edit';
  isSubmitting?: boolean;
}

const normalizeValues = (values: UserFormValues) => ({
  ...values,
  password: values.password?.trim() || undefined,
  phoneNumber: values.phoneNumber?.trim() || undefined,
  dateOfBirth: values.dateOfBirth?.trim() || undefined,
  gender: values.gender?.trim() || undefined,
  address: values.address?.trim() || undefined,
  profileImage: values.profileImage?.trim() || undefined,
});

const UserForm = ({ defaultValues, onSubmit, onCancel, mode = 'create', isSubmitting = false }: UserFormProps) => {
  const schema = useMemo(() => {
    if (mode === 'create') {
      return baseSchema.extend({
        password: z.string().min(6, 'Mat khau toi thieu 6 ky tu'),
      });
    }
    return baseSchema;
  }, [mode]);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
  } = useForm<UserFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      username: '',
      email: '',
      fullName: '',
      password: '',
      phoneNumber: '',
      dateOfBirth: '',
      gender: '',
      address: '',
      profileImage: '',
      role: 'user',
      status: 'active',
      ...defaultValues,
    },
  });
  const [isUploading, setUploading] = useState(false);

  const handleFormSubmit = handleSubmit(async (values) => {
    await onSubmit(normalizeValues(values));
  });

  const handleUpload = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setUploading(true);
    try {
      const uploaded = await uploadImage(file);
      setValue('profileImage', uploaded.url);
    } catch (error) {
      console.error('Upload user profile image failed', error);
      window.alert('Tai anh that bai, vui long thu lai.');
    } finally {
      setUploading(false);
      event.target.value = '';
    }
  };

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <div className="form__grid form__grid--two">
        <FormField label="Ten dang nhap" htmlFor="username" required error={errors.username?.message}>
          <input id="username" {...register('username')} placeholder="Ten dang nhap" />
        </FormField>

        <FormField label="Email" htmlFor="email" required error={errors.email?.message}>
          <input id="email" {...register('email')} placeholder="email@example.com" type="email" />
        </FormField>

        <FormField label="Ho va ten" htmlFor="fullName" required error={errors.fullName?.message}>
          <input id="fullName" {...register('fullName')} placeholder="Ho ten day du" />
        </FormField>

        {mode === 'create' && (
          <FormField label="Mat khau" htmlFor="password" required error={errors.password?.message}>
            <input id="password" {...register('password')} type="password" placeholder="******" />
          </FormField>
        )}

        <FormField label="So dien thoai" htmlFor="phoneNumber" error={errors.phoneNumber?.message}>
          <input id="phoneNumber" {...register('phoneNumber')} placeholder="0123456789" />
        </FormField>

        <FormField label="Ngay sinh" htmlFor="dateOfBirth" error={errors.dateOfBirth?.message}>
          <input id="dateOfBirth" {...register('dateOfBirth')} type="date" />
        </FormField>

        <FormField label="Gioi tinh" htmlFor="gender" error={errors.gender?.message}>
          <input id="gender" {...register('gender')} placeholder="Nam/Nu" />
        </FormField>

        <FormField label="Anh dai dien" htmlFor="profileImage" error={errors.profileImage?.message}>
          <input id="profileImage" {...register('profileImage')} placeholder="URL anh" />
          <input type="file" accept="image/*" onChange={handleUpload} disabled={isUploading} />
          {isUploading && <small className="text-muted">Dang tai anh...</small>}
        </FormField>
      </div>

      <FormField label="Dia chi" htmlFor="address" error={errors.address?.message}>
        <textarea id="address" {...register('address')} rows={3} placeholder="Dia chi nguoi dung" />
      </FormField>

      <div className="form__grid form__grid--two">
        <FormField label="Vai tro" htmlFor="role" required error={errors.role?.message}>
          <select id="role" {...register('role')}>
            <option value="admin">Admin</option>
            <option value="user">User</option>
          </select>
        </FormField>

        <FormField label="Trang thai" htmlFor="status" required error={errors.status?.message}>
          <select id="status" {...register('status')}>
            <option value="active">Hoat dong</option>
            <option value="inactive">Tam khoa</option>
          </select>
        </FormField>
      </div>

      <div className="form__actions">
        <Button variant="ghost" type="button" onClick={onCancel}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          {mode === 'create' ? 'Tao moi' : 'Luu thay doi'}
        </Button>
      </div>
    </form>
  );
};

export default UserForm;

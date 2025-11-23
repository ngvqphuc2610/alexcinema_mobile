import { useState, type ChangeEvent } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';
import type { MovieStatus } from '../../types';
import { uploadImage } from '../../api/uploads';

const movieStatusOptions: Record<MovieStatus, string> = {
  'coming soon': 'Sap chieu',
  'now showing': 'Dang chieu',
  expired: 'Ngung chieu',
};

const schema = z.object({
  title: z.string().min(1, 'Nhap ten phim'),
  originalTitle: z.string().optional().or(z.literal('')),
  director: z.string().optional().or(z.literal('')),
  actors: z.string().optional().or(z.literal('')),
  duration: z.coerce.number().min(1, 'Thoi luong phai lon hon 0'),
  releaseDate: z.string().min(1, 'Chon ngay khoi chieu'),
  endDate: z.string().optional().or(z.literal('')),
  language: z.string().optional().or(z.literal('')),
  subtitle: z.string().optional().or(z.literal('')),
  country: z.string().optional().or(z.literal('')),
  description: z.string().optional().or(z.literal('')),
  posterImage: z.string().optional().or(z.literal('')),
  bannerImage: z.string().optional().or(z.literal('')),
  trailerUrl: z.string().optional().or(z.literal('')),
  ageRestriction: z.string().optional().or(z.literal('')),
  status: z.enum(['coming soon', 'now showing', 'expired']),
});

export type MovieFormValues = z.infer<typeof schema>;

export interface MovieFormProps {
  defaultValues?: Partial<MovieFormValues>;
  onSubmit: (values: MovieFormValues) => Promise<void> | void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

const normalize = (values: MovieFormValues) => ({
  ...values,
  originalTitle: values.originalTitle?.trim() || undefined,
  director: values.director?.trim() || undefined,
  actors: values.actors?.trim() || undefined,
  endDate: values.endDate?.trim() || undefined,
  language: values.language?.trim() || undefined,
  subtitle: values.subtitle?.trim() || undefined,
  country: values.country?.trim() || undefined,
  description: values.description?.trim() || undefined,
  posterImage: values.posterImage?.trim() || undefined,
  bannerImage: values.bannerImage?.trim() || undefined,
  trailerUrl: values.trailerUrl?.trim() || undefined,
  ageRestriction: values.ageRestriction?.trim() || undefined,
});

const MovieForm = ({ defaultValues, onSubmit, onCancel, isSubmitting = false }: MovieFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
  } = useForm<MovieFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      title: '',
      originalTitle: '',
      director: '',
      actors: '',
      duration: 120,
      releaseDate: '',
      endDate: '',
      language: '',
      subtitle: '',
      country: '',
      description: '',
      posterImage: '',
      bannerImage: '',
      trailerUrl: '',
      ageRestriction: '',
      status: 'coming soon',
      ...defaultValues,
    },
  });

  const [uploadingField, setUploadingField] = useState<'posterImage' | 'bannerImage' | null>(null);

  const handleFormSubmit = handleSubmit(async (values) => onSubmit(normalize(values)));

  const handleFileUpload = async (event: ChangeEvent<HTMLInputElement>, field: 'posterImage' | 'bannerImage') => {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }

    setUploadingField(field);
    try {
      const response = await uploadImage(file);
      setValue(field, response.url);
    } catch (error) {
      console.error('Failed to upload image', error);
      window.alert('Tai anh that bai, vui long thu lai.');
    } finally {
      setUploadingField(null);
      // allow uploading the same file again if needed
      event.target.value = '';
    }
  };

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <FormField label="Ten phim" htmlFor="movie-title" required error={errors.title?.message}>
        <input id="movie-title" {...register('title')} placeholder="Ten phim chinh" />
      </FormField>

      <div className="form__grid form__grid--two">
        <FormField label="Ten goc" htmlFor="movie-originalTitle" error={errors.originalTitle?.message}>
          <input id="movie-originalTitle" {...register('originalTitle')} placeholder="Ten tieng Anh..." />
        </FormField>

        <FormField label="Dao dien" htmlFor="movie-director" error={errors.director?.message}>
          <input id="movie-director" {...register('director')} placeholder="Ten dao dien" />
        </FormField>
      </div>

      <FormField label="Dien vien" htmlFor="movie-actors" error={errors.actors?.message}>
        <textarea
          id="movie-actors"
          {...register('actors')}
          rows={3}
          placeholder="Danh sach dien vien chinh, cach nhau boi dau phay"
        />
      </FormField>

      <div className="form__grid form__grid--three">
        <FormField label="Thoi luong (phut)" htmlFor="movie-duration" required error={errors.duration?.message}>
          <input id="movie-duration" type="number" min={1} {...register('duration', { valueAsNumber: true })} />
        </FormField>
        <FormField label="Ngay khoi chieu" htmlFor="movie-releaseDate" required error={errors.releaseDate?.message}>
          <input id="movie-releaseDate" type="date" {...register('releaseDate')} />
        </FormField>
        <FormField label="Ngay ket thuc" htmlFor="movie-endDate" error={errors.endDate?.message}>
          <input id="movie-endDate" type="date" {...register('endDate')} />
        </FormField>
      </div>

      <div className="form__grid form__grid--three">
        <FormField label="Ngon ngu" htmlFor="movie-language" error={errors.language?.message}>
          <input id="movie-language" {...register('language')} />
        </FormField>
        <FormField label="Phu de" htmlFor="movie-subtitle" error={errors.subtitle?.message}>
          <input id="movie-subtitle" {...register('subtitle')} />
        </FormField>
        <FormField label="Quoc gia" htmlFor="movie-country" error={errors.country?.message}>
          <input id="movie-country" {...register('country')} />
        </FormField>
      </div>

      <FormField label="Mo ta" htmlFor="movie-description" error={errors.description?.message}>
        <textarea id="movie-description" {...register('description')} rows={4} placeholder="Tom tat noi dung phim" />
      </FormField>

      <div className="form__grid form__grid--two">
        <FormField label="Poster" htmlFor="movie-posterImage" error={errors.posterImage?.message}>
          <input id="movie-posterImage" {...register('posterImage')} placeholder="URL poster" />
          <input
            type="file"
            accept="image/*"
            onChange={(event) => handleFileUpload(event, 'posterImage')}
            disabled={uploadingField === 'posterImage'}
          />
          {uploadingField === 'posterImage' && <small className="text-muted">Dang tai anh...</small>}
        </FormField>
        <FormField label="Banner" htmlFor="movie-bannerImage" error={errors.bannerImage?.message}>
          <input id="movie-bannerImage" {...register('bannerImage')} placeholder="URL banner" />
          <input
            type="file"
            accept="image/*"
            onChange={(event) => handleFileUpload(event, 'bannerImage')}
            disabled={uploadingField === 'bannerImage'}
          />
          {uploadingField === 'bannerImage' && <small className="text-muted">Dang tai anh...</small>}
        </FormField>
      </div>

      <div className="form__grid form__grid--two">
        <FormField label="Trailer" htmlFor="movie-trailerUrl" error={errors.trailerUrl?.message}>
          <input id="movie-trailerUrl" {...register('trailerUrl')} placeholder="URL trailer" />
        </FormField>
        <FormField label="Gioi han tuoi" htmlFor="movie-ageRestriction" error={errors.ageRestriction?.message}>
          <input id="movie-ageRestriction" {...register('ageRestriction')} placeholder="VD: C13, P" />
        </FormField>
      </div>

      <FormField label="Trang thai" htmlFor="movie-status" required error={errors.status?.message}>
        <select id="movie-status" {...register('status')}>
          {Object.entries(movieStatusOptions).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
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

export default MovieForm;

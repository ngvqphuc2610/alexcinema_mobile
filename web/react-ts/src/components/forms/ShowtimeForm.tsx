import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import Button from '../common/Button';
import FormField from './FormField';
import type { Movie, Screen } from '../../types';

const schema = z.object({
  idMovie: z.coerce.number().optional(),
  idScreen: z.coerce.number().optional(),
  showDate: z.string().min(1, 'Chon ngay chieu'),
  startTime: z.string().min(1, 'Nhap gio bat dau'),
  endTime: z.string().min(1, 'Nhap gio ket thuc'),
  format: z.string().optional().or(z.literal('')),
  language: z.string().optional().or(z.literal('')),
  subtitle: z.string().optional().or(z.literal('')),
  status: z.string().optional().or(z.literal('')),
  price: z.coerce.number().min(0, 'Gia ve khong hop le'),
});

export type ShowtimeFormValues = z.infer<typeof schema>;

export interface ShowtimeFormProps {
  movies: Movie[];
  screens: Screen[];
  defaultValues?: Partial<ShowtimeFormValues>;
  onSubmit: (values: ShowtimeFormValues) => Promise<void> | void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

const normalize = (values: ShowtimeFormValues) => ({
  ...values,
  idMovie: Number.isNaN(values.idMovie) ? undefined : values.idMovie,
  idScreen: Number.isNaN(values.idScreen) ? undefined : values.idScreen,
  format: values.format?.trim() || undefined,
  language: values.language?.trim() || undefined,
  subtitle: values.subtitle?.trim() || undefined,
  status: values.status?.trim() || undefined,
});

const ShowtimeForm = ({
  movies,
  screens,
  defaultValues,
  onSubmit,
  onCancel,
  isSubmitting = false,
}: ShowtimeFormProps) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ShowtimeFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      showDate: '',
      startTime: '',
      endTime: '',
      price: 0,
      ...defaultValues,
    },
  });

  const handleFormSubmit = handleSubmit(async (values) => onSubmit(normalize(values)));

  return (
    <form className="form" onSubmit={handleFormSubmit}>
      <div className="form__grid form__grid--two">
        <FormField label="Phim" htmlFor="showtime-movie" error={errors.idMovie?.message}>
          <select id="showtime-movie" {...register('idMovie')}>
            <option value="">-- Chon phim --</option>
            {movies.map((movie) => (
              <option key={movie.id_movie} value={movie.id_movie}>
                {movie.title}
              </option>
            ))}
          </select>
        </FormField>

        <FormField label="Phong chieu" htmlFor="showtime-screen" error={errors.idScreen?.message}>
          <select id="showtime-screen" {...register('idScreen')}>
            <option value="">-- Chon phong --</option>
            {screens.map((screen) => (
              <option key={screen.id_screen} value={screen.id_screen}>
                {screen.screen_name}
              </option>
            ))}
          </select>
        </FormField>
      </div>

      <div className="form__grid form__grid--three">
        <FormField label="Ngay chieu" htmlFor="showtime-showDate" required error={errors.showDate?.message}>
          <input id="showtime-showDate" type="date" {...register('showDate')} />
        </FormField>
        <FormField label="Gio bat dau" htmlFor="showtime-startTime" required error={errors.startTime?.message}>
          <input id="showtime-startTime" type="time" {...register('startTime')} />
        </FormField>
        <FormField label="Gio ket thuc" htmlFor="showtime-endTime" required error={errors.endTime?.message}>
          <input id="showtime-endTime" type="time" {...register('endTime')} />
        </FormField>
      </div>

      <div className="form__grid form__grid--three">
        <FormField label="Dinh dang" htmlFor="showtime-format" error={errors.format?.message}>
          <input id="showtime-format" {...register('format')} placeholder="2D, 3D..." />
        </FormField>
        <FormField label="Ngon ngu" htmlFor="showtime-language" error={errors.language?.message}>
          <input id="showtime-language" {...register('language')} placeholder="Tieng Viet..." />
        </FormField>
        <FormField label="Phu de" htmlFor="showtime-subtitle" error={errors.subtitle?.message}>
          <input id="showtime-subtitle" {...register('subtitle')} placeholder="Subtitle" />
        </FormField>
      </div>

      <div className="form__grid form__grid--two">
        <FormField label="Trang thai" htmlFor="showtime-status" error={errors.status?.message}>
          <input id="showtime-status" {...register('status')} placeholder="active, cancelled..." />
        </FormField>

        <FormField label="Gia ve" htmlFor="showtime-price" required error={errors.price?.message}>
          <input id="showtime-price" type="number" min={0} step="0.01" {...register('price', { valueAsNumber: true })} />
        </FormField>
      </div>

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

export default ShowtimeForm;


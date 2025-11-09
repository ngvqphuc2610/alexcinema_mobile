import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import Card from '../../components/common/Card';
import DataTable from '../../components/common/DataTable';
import SearchInput from '../../components/common/SearchInput';
import Pagination from '../../components/common/Pagination';
import Button from '../../components/common/Button';
import EmptyState from '../../components/common/EmptyState';
import LoadingOverlay from '../../components/common/LoadingOverlay';
import ErrorState from '../../components/common/ErrorState';
import Modal from '../../components/common/Modal';
import MovieForm from '../../components/forms/MovieForm';
import type { MovieFormValues } from '../../components/forms/MovieForm';
import StatusDot from '../../components/common/StatusDot';
import { fetchMovies, createMovie, updateMovie, deleteMovie } from '../../api/movies';
import type { Movie } from '../../types';
import { formatDate, formatStatus } from '../../utils/format';

const mapMovieToFormValues = (movie: Movie): MovieFormValues => ({
  title: movie.title,
  originalTitle: movie.original_title ?? '',
  director: movie.director ?? '',
  actors: movie.actors ?? '',
  duration: movie.duration,
  releaseDate: movie.release_date?.substring(0, 10) ?? '',
  endDate: movie.end_date?.substring(0, 10) ?? '',
  language: movie.language ?? '',
  subtitle: movie.subtitle ?? '',
  country: movie.country ?? '',
  description: movie.description ?? '',
  posterImage: movie.poster_image ?? '',
  bannerImage: movie.banner_image ?? '',
  trailerUrl: movie.trailer_url ?? '',
  ageRestriction: movie.age_restriction ?? '',
  status: movie.status,
});

const toMoviePayload = (values: MovieFormValues) => ({
  title: values.title,
  originalTitle: values.originalTitle || undefined,
  director: values.director || undefined,
  actors: values.actors || undefined,
  duration: values.duration,
  releaseDate: values.releaseDate,
  endDate: values.endDate || undefined,
  language: values.language || undefined,
  subtitle: values.subtitle || undefined,
  country: values.country || undefined,
  description: values.description || undefined,
  posterImage: values.posterImage || undefined,
  bannerImage: values.bannerImage || undefined,
  trailerUrl: values.trailerUrl || undefined,
  ageRestriction: values.ageRestriction || undefined,
  status: values.status,
});

const MoviesPage = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [editingMovie, setEditingMovie] = useState<Movie | null>(null);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['movies', { page, search }],
    queryFn: () => fetchMovies({ page, search: search || undefined }),
    placeholderData: keepPreviousData,
  });

  const createMutation = useMutation({
    mutationFn: createMovie,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['movies'] });
      setCreateModalOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: (payload: { id: number; data: MovieFormValues }) => updateMovie(payload.id, toMoviePayload(payload.data)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['movies'] });
      setEditingMovie(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteMovie(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['movies'] }),
  });

  const items = data?.items ?? [];
  const meta = data?.meta;

  const handleDelete = (movie: Movie) => {
    if (window.confirm(`Ban chac chan muon xoa phim "${movie.title}"?`)) {
      deleteMutation.mutate(movie.id_movie);
    }
  };

  const columns = useMemo(
    () => [
      {
        key: 'title',
        title: 'Ten phim',
        render: (movie: Movie) => movie.title,
      },
      {
        key: 'duration',
        title: 'Thoi luong',
        render: (movie: Movie) => `${movie.duration} phut`,
      },
      {
        key: 'release',
        title: 'Khoi chieu',
        render: (movie: Movie) => formatDate(movie.release_date),
      },
      {
        key: 'status',
        title: 'Trang thai',
        render: (movie: Movie) => <StatusDot status={movie.status}>{formatStatus(movie.status)}</StatusDot>,
      },
      {
        key: 'language',
        title: 'Ngon ngu',
        render: (movie: Movie) => movie.language ?? '--',
      },
      {
        key: 'actions',
        title: 'Thao tac',
        render: (movie: Movie) => (
          <div className="table-actions">
            <button type="button" title="Chinh sua" onClick={() => setEditingMovie(movie)}>
              <Pencil size={16} />
            </button>
            <button type="button" title="Xoa" className="danger" onClick={() => handleDelete(movie)}>
              <Trash2 size={16} />
            </button>
          </div>
        ),
      },
    ],
    [],
  );

  return (
    <div className="page">
      <Card
        title="Quan ly phim"
        description="Them, chinh sua va theo doi danh muc phim."
        actions={
          <div className="card__actions-group">
            <SearchInput
              placeholder="Tim kiem phim..."
              onSearch={(value) => {
                setPage(1);
                setSearch(value);
              }}
            />
            <Button leftIcon={<Plus size={16} />} onClick={() => setCreateModalOpen(true)}>
              Them phim
            </Button>
          </div>
        }
      >
        {isLoading && <LoadingOverlay />}
        {isError && <ErrorState description="Khong tai duoc danh sach phim." onRetry={() => refetch()} />}
        {!isLoading && items.length === 0 && <EmptyState description="Chua co phim nao trong he thong." />}
        {!isLoading && items.length > 0 && (
          <>
            <DataTable data={items} columns={columns} rowKey={(movie) => movie.id_movie} />
            {meta && (
              <Pagination
                page={meta.page}
                totalPages={meta.totalPages}
                total={meta.total}
                onChange={(nextPage) => setPage(nextPage)}
              />
            )}
          </>
        )}
      </Card>

      <Modal open={isCreateModalOpen} onClose={() => setCreateModalOpen(false)} title="Them phim moi">
        <MovieForm
          isSubmitting={createMutation.isPending}
          onCancel={() => setCreateModalOpen(false)}
          onSubmit={(values) => createMutation.mutate(toMoviePayload(values))}
        />
      </Modal>

      <Modal
        open={Boolean(editingMovie)}
        onClose={() => {
          if (!updateMutation.isPending) {
            setEditingMovie(null);
          }
        }}
        title={editingMovie ? `Chinh sua: ${editingMovie.title}` : ''}
      >
        {editingMovie && (
          <MovieForm
            defaultValues={mapMovieToFormValues(editingMovie)}
            isSubmitting={updateMutation.isPending}
            onCancel={() => setEditingMovie(null)}
            onSubmit={(values) =>
              updateMutation.mutate({
                id: editingMovie.id_movie,
                data: values,
              })
            }
          />
        )}
      </Modal>
    </div>
  );
};

export default MoviesPage;

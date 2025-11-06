'use client';

import { useEffect, useState } from 'react';
import { apiFetch } from '@/lib/api';
import { useAuth } from '@/hooks/useAuth';
import { DataTable, Column } from '@/components/DataTable';
import { Pagination } from '@/components/Pagination';

interface Movie {
  id_movie: number;
  title: string;
  status: string;
  release_date: string;
  end_date: string | null;
  duration: number;
}

interface MoviesResponse {
  items: Movie[];
  meta: {
    page: number;
    totalPages: number;
  };
}

const COLUMNS: Column<Movie>[] = [
  { key: 'title', header: 'Tên phim' },
  {
    key: 'status',
    header: 'Trạng thái',
    render: (item) => {
      switch (item.status) {
        case 'now showing':
          return 'Đang chiếu';
        case 'coming soon':
          return 'Sắp chiếu';
        case 'expired':
          return 'Ngừng chiếu';
        default:
          return item.status;
      }
    },
  },
  {
    key: 'release_date',
    header: 'Khởi chiếu',
    render: (item) => new Date(item.release_date).toLocaleDateString('vi-VN'),
  },
  {
    key: 'end_date',
    header: 'Kết thúc',
    render: (item) => (item.end_date ? new Date(item.end_date).toLocaleDateString('vi-VN') : 'Chưa xác định'),
  },
  {
    key: 'duration',
    header: 'Thời lượng',
    render: (item) => `${item.duration} phút`,
  },
];

export default function MoviesPage() {
  const { token } = useAuth();
  const [data, setData] = useState<Movie[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const load = async () => {
      if (!token) return;
      setLoading(true);
      setError(null);
      try {
        const response = await apiFetch<MoviesResponse>(`/movies?page=${page}&limit=10`, {}, token);
        setData(response.items);
        setTotalPages(response.meta.totalPages || 1);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không thể tải danh sách phim');
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [page, token]);

  return (
    <div className="space-y-6">
      <header>
        <h2 className="text-xl font-semibold text-slate-900">Danh sách phim</h2>
        <p className="text-sm text-slate-500">Quản lý lịch chiếu và trạng thái từng bộ phim.</p>
      </header>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-600">{error}</div>}

      <DataTable data={data} columns={COLUMNS} keyExtractor={(item) => item.id_movie} loading={loading} />

      <Pagination page={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  );
}

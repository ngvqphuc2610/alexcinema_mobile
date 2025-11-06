'use client';

import { useEffect, useState } from 'react';
import { apiFetch } from '@/lib/api';
import { useAuth } from '@/hooks/useAuth';
import { DataTable, Column } from '@/components/DataTable';
import { Pagination } from '@/components/Pagination';

interface Promotion {
  id_promotions: number;
  promotion_code: string;
  title: string;
  status: string;
  start_date: string;
  end_date: string | null;
  discount_percent: string;
  discount_amount: string;
}

interface PromotionsResponse {
  items: Promotion[];
  meta: {
    page: number;
    totalPages: number;
  };
}

const COLUMNS: Column<Promotion>[] = [
  { key: 'promotion_code', header: 'Mã KM' },
  { key: 'title', header: 'Tên chương trình' },
  {
    key: 'status',
    header: 'Trạng thái',
    render: (item) => (item.status === 'active' ? 'Đang hoạt động' : 'Tạm ngưng'),
  },
  {
    key: 'discount_percent',
    header: 'Ưu đãi',
    render: (item) =>
      Number(item.discount_percent) > 0
        ? `${Number(item.discount_percent).toFixed(0)}%`
        : `${Number(item.discount_amount).toLocaleString('vi-VN')}đ`,
  },
  {
    key: 'start_date',
    header: 'Bắt đầu',
    render: (item) => new Date(item.start_date).toLocaleDateString('vi-VN'),
  },
  {
    key: 'end_date',
    header: 'Kết thúc',
    render: (item) => (item.end_date ? new Date(item.end_date).toLocaleDateString('vi-VN') : 'Không giới hạn'),
  },
];

export default function PromotionsPage() {
  const { token } = useAuth();
  const [data, setData] = useState<Promotion[]>([]);
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
        const response = await apiFetch<PromotionsResponse>(`/promotions?page=${page}&limit=10`, {}, token);
        setData(response.items);
        setTotalPages(response.meta.totalPages || 1);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không thể tải danh sách khuyến mãi');
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [page, token]);

  return (
    <div className="space-y-6">
      <header>
        <h2 className="text-xl font-semibold text-slate-900">Chương trình khuyến mãi</h2>
        <p className="text-sm text-slate-500">Theo dõi các mã giảm giá và ưu đãi đang áp dụng.</p>
      </header>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-600">{error}</div>}

      <DataTable data={data} columns={COLUMNS} keyExtractor={(item) => item.id_promotions} loading={loading} />

      <Pagination page={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  );
}
